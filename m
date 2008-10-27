From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 01/05]IPtablestng/UserSpace - patch build files
Date: Mon, 27 Oct 2008 08:52:18 +0330 (IRST)
Message-ID: <20081027052218.37C08C64092@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.185.161.20] ([85.185.161.20]:46695 "EHLO host1.ystp.ac.ir"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbYJ0FoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 01:44:04 -0400
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patching Makefile.am to compile only ipv4 commands.

all of the ipv6 statements are removed from 'Makefile.am'. run 'automake' before configuring the package (to create 'Makefile.in').

diff --git a/Makefile.am b/Makefile.am
index 49edbf8..8dc941d 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -9,7 +9,7 @@ SUBDIRS         += libipq
 endif
 
 # libiptc
-libiptc_libiptc_a_SOURCES = libiptc/libip4tc.c libiptc/libip6tc.c
+libiptc_libiptc_a_SOURCES = libiptc/libip4tc.c 
 
 # iptables, dynamic
 iptables_SOURCES          = iptables-standalone.c iptables.c xtables.c
@@ -38,60 +38,30 @@ iptables_static_LDADD     = -lm libiptc/libiptc.a extensions/libext4.a
 
 iptables_xml_SOURCES      = iptables-xml.c
 
-# ip6tables, dynamic
-ip6tables_SOURCES         = ip6tables-standalone.c ip6tables.c xtables.c
-ip6tables_LDFLAGS         = -rdynamic
-ip6tables_LDADD           = -ldl -lm libiptc/libiptc.a extensions/libext6.a
-
-ip6tables_multi_SOURCES   = ip6tables-multi.c ip6tables-save.c \
-                            ip6tables-restore.c ip6tables-standalone.c \
-                            ip6tables.c xtables.c
-ip6tables_multi_CFLAGS    = ${AM_CFLAGS} -DIPTABLES_MULTI
-ip6tables_multi_LDFLAGS   = ${ip6tables_LDFLAGS}
-ip6tables_multi_LDADD     = ${ip6tables_LDADD}
-
-ip6tables_restore_SOURCES = ip6tables-restore.c ip6tables.c xtables.c
-ip6tables_restore_LDFLAGS = ${ip6tables_LDFLAGS}
-ip6tables_restore_LDADD   = ${ip6tables_LDADD}
-
-ip6tables_save_SOURCES    = ip6tables-save.c ip6tables.c xtables.c
-ip6tables_save_LDFLAGS    = ${ip6tables_LDFLAGS}
-ip6tables_save_LDADD      = ${ip6tables_LDADD}
-
-# iptables-multi, semi-static
-ip6tables_static_SOURCES    = ${ip6tables_multi_SOURCES}
-ip6tables_static_CFLAGS     = ${ip6tables_multi_CFLAGS} -DNO_SHARED_LIBS=1
-ip6tables_static_LDADD      = -lm libiptc/libiptc.a extensions/libext6.a
-
 noinst_LIBRARIES := libiptc/libiptc.a
 bin_PROGRAMS     := iptables-xml
 sbin_PROGRAMS    :=
 noinst_PROGRAMS  :=
 man_MANS         := iptables.8 iptables-restore.8 iptables-save.8 \
-                    iptables-xml.8 ip6tables.8 ip6tables-restore.8 \
-                    ip6tables-save.8
-CLEANFILES       := iptables.8 ip6tables.8
+                    iptables-xml.8 
+CLEANFILES       := iptables.8 
 if ENABLE_DEVEL
-include_HEADERS  := include/xtables.h include/iptables.h include/ip6tables.h
+include_HEADERS  := include/xtables.h include/iptables.h 
 iptcdir           = ${includedir}/libiptc
 iptc_HEADERS     := include/libiptc/libxtc.h \
                     include/libiptc/ipt_kernel_headers.h
 endif
 
 if ENABLE_STATIC
-sbin_PROGRAMS += iptables-static ip6tables-static
+sbin_PROGRAMS += iptables-static 
 endif
 if ENABLE_SHARED
-sbin_PROGRAMS += iptables iptables-multi iptables-restore iptables-save \
-                 ip6tables ip6tables-multi ip6tables-restore ip6tables-save
+sbin_PROGRAMS += iptables iptables-multi iptables-restore iptables-save 
 endif
 
 iptables.8: ${srcdir}/iptables.8.in extensions/matches4.man extensions/targets4.man
 	${AM_VERBOSE_GEN} sed -e '/@MATCH@/ r extensions/matches4.man' -e '/@TARGET@/ r extensions/targets4.man' $< >$@;
 
-ip6tables.8: ${srcdir}/ip6tables.8.in extensions/matches6.man extensions/targets6.man
-	${AM_VERBOSE_GEN} sed -e '/@MATCH@/ r extensions/matches6.man' -e '/@TARGET@/ r extensions/targets6.man' $< >$@;
-
 extensions/%:
 	${MAKE} ${AM_MAKEFLAGS} -C $(@D) $(@F)
 

