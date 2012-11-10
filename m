From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH/RFC] iproute2: drop libresolv
Date: Sat, 10 Nov 2012 13:22:10 +0100
Message-ID: <20121110122209.GA15100@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h22.telenor.se ([195.54.99.197]:39412 "EHLO
	smtprelay-h22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab2KJMVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2012 07:21:42 -0500
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-h22.telenor.se (Postfix) with ESMTP id 5E084EAF89
	for <netdev@vger.kernel.org>; Sat, 10 Nov 2012 13:21:39 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

While building the iproute package in Debian I get warnings from
package helpers like this:

dpkg-shlibdeps: warning: package could avoid a useless dependency if debian/iproute/sbin/tc debian/iproute/usr/bin/lnstat debian/iproute/bin/ip debian/iproute/bin/ss debian/iproute/sbin/bridge debian/iproute/sbin/rtmon were not linked against libresolv.so.2 (they use none of the library's symbols)

The -lresolv in ./Makefile seems to come from pre-historic times (before
iproute2 git history, possibly from libc5/pre-glibc days).
I couldn't find out if/why there was any reason for linking to libresolv.
Does anyone know if there are any valid reasons for keeping it still?

If not, I'd be happy to see it go.... while at it I also removed includes
of <resolv.h> which I also couldn't find any reason for, but this is
just an added bonus of the patch (and there are probably more unneeded
includes that could be dropped in the same sources).


Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/Makefile b/Makefile
index 917862b..46a5ad9 100644
--- a/Makefile
+++ b/Makefile
@@ -20,10 +20,6 @@ endif
 
 DEFINES+=-DCONFDIR=\"$(CONFDIR)\"
 
-#options if you have a bind>=4.9.4 libresolv (or, maybe, glibc)
-LDLIBS=-lresolv
-ADDLIB=
-
 #options for decnet
 ADDLIB+=dnet_ntop.o dnet_pton.o
 
diff --git a/lib/utils.c b/lib/utils.c
index d80f79b..7ecaab3 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -20,7 +20,6 @@
 #include <string.h>
 #include <netdb.h>
 #include <arpa/inet.h>
-#include <resolv.h>
 #include <asm/types.h>
 #include <linux/pkt_sched.h>
 #include <time.h>
diff --git a/misc/ss.c b/misc/ss.c
index a0ab2e9..b45f5ba 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -22,7 +22,6 @@
 #include <errno.h>
 #include <netdb.h>
 #include <arpa/inet.h>
-#include <resolv.h>
 #include <dirent.h>
 #include <fnmatch.h>
 #include <getopt.h>
