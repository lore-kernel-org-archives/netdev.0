From: Andreas Henriksson <andreas@fatal.se>
Subject: [iproute] debian patches.
Date: Sun, 20 Apr 2008 15:44:58 +0200
Message-ID: <1208699098.14464.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:46600 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752305AbYDTOdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 10:33:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Here's the current set of patches still pending in the debian packaging
"patches" branch, now rebased on top of 727d4 (v2.6.25-080417).

git://git.debian.org/git/collab-maint/pkg-iproute.git



commit 44a034869141d3de0a3a155961641831bc50b606
Author: Andreas Henriksson <andreas@fatal.se>
Date:   Sat Jan 12 17:17:02 2008 +0100

    document promote_secondaries
    
    Write something about the tweak to enable promoting secondary addresses
    instead of deleting them together with the primary address as discussed
    in this thread on the netdev mailing list:
    http://www.spinics.net/lists/netdev/msg52294.html
    
    The claim that this is supported since 2.6.15 is based on looking at
    changes to net/ipv4/devinet.c in the linux-2.6 git tree:
    
    Commit to add support:
    2005-05-30      Harald Welte
    8f937c6099858eee15fae14009dcbd05177fa91d
    
    Commit to fix bug:
    2005-11-22      Jamal Hadi Salim
    0ff60a45678e67b2547256a636fd00c1667ce4fa
    
    Version 2.6.15 was released 2006-01-03 and seems to include the code from
    both the above commits.

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index fe38f99..cc0e07d 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -751,6 +751,11 @@ An IP address becomes secondary if another address with the same
 prefix bits already exists. The first address is primary.
 It is the leader of the group of all secondary addresses. When the leader
 is deleted, all secondaries are purged too.
+There is a tweak in \verb|/proc/sys/net/ipv4/conf/<dev>/promote_secondaries|
+which activate secondaries promotion when a primary is deleted.
+To permanently enable this feature on all devices add
+\verb|net.ipv4.conf.all.promote_secondaries=1| to \verb|/etc/sysctl.conf|.
+This tweak is available in linux 2.6.15 and later.
 
 
 \item \verb|dynamic|

commit ee98d069b043eba2c711253f3b988dea585d6256
Author: Andreas Henriksson <andreas@fatal.se>
Date:   Sun Apr 20 11:25:31 2008 +0200

    Fix typos (syntax error) in ip(8) manpage.
    
    This one also caught by lintian (debian package checker tool).

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 976b34b..da314f3 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -437,7 +437,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .ti -8
 .IR MODE " := "
 .RB " [ " transport " | " tunnel " | " ro " | " beet " ] "
-.b (default=transport)
+.B (default=transport)
 
 .ti -8
 .IR FLAG-LIST " := "
@@ -561,7 +561,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .ti -8
 .IR PTYPE " := "
 .RB " [ " main " | " sub " ] "
-.b (default=main)
+.B (default=main)
 
 .ti -8
 .IR DIR " := "
@@ -593,7 +593,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .ti -8
 .IR ACTION " := "
 .RB " [ " allow " | " block " ]"
-.b (default=allow)
+.B (default=allow)
 
 .ti -8
 .IR LIMIT-LIST " := "
@@ -614,7 +614,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 
 .ti -8
 .IR TMPL-LIST " := "
-.b " [ "
+.B " [ "
 .IR TMPL-LIST " ] | "
 .RB " [ " tmpl
 .IR TMPL " ] "
@@ -647,12 +647,12 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .ti -8
 .IR MODE " := "
 .RB " [ " transport " | " tunnel " | " beet " ] "
-.b (default=transport)
+.B (default=transport)
 
 .ti -8
 .IR LEVEL " := "
 .RB " [ " required " | " use " ] "
-.b (default=required)
+.B (default=required)
 
 .ti -8
 .BR "ip xfrm monitor" " [ " all " | "

commit e26dac936eb754c55421461bcc63207d0cb957dc
Author: Andreas Henriksson <andreas@fatal.se>
Date:   Thu Jan 3 16:48:56 2008 +0100

    Add routel and routef man page.

diff --git a/Makefile b/Makefile
index de04176..723eb5d 100644
--- a/Makefile
+++ b/Makefile
@@ -56,6 +56,7 @@ install: all
 	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/rtstat.8
 	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/ctstat.8
 	ln -sf rtacct.8  $(DESTDIR)$(MANDIR)/man8/nstat.8
+	ln -sf routel.8  $(DESTDIR)$(MANDIR)/man8/routef.8
 	install -m 0755 -d $(DESTDIR)$(MANDIR)/man3
 	install -m 0644 $(shell find man/man3 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man3
 
diff --git a/man/man8/routel.8 b/man/man8/routel.8
new file mode 100644
index 0000000..cdf8f55
--- /dev/null
+++ b/man/man8/routel.8
@@ -0,0 +1,32 @@
+.TH "ROUTEL" "8" "3 Jan, 2008" "iproute2" "Linux"
+.SH "NAME"
+.LP 
+routel \- list routes with pretty output format
+.br
+routef \- flush routes
+.SH "SYNTAX"
+.LP 
+routel [\fItablenr\fP [\fIraw ip args...\fP]]
+.br 
+routef
+.SH "DESCRIPTION"
+.LP 
+These programs are a set of helper scripts you can use instead of raw iproute2 commands.
+.br
+The routel script will list routes in a format that some might consider easier to interpret then the ip route list equivalent.
+.br
+The routef script does not take any arguments and will simply flush the routing table down the drain. Beware! This means deleting all routes which will make your network unusable!
+
+.SH "FILES"
+.LP 
+\fI/usr/bin/routef\fP 
+.br 
+\fI/usr/bin/routel\fP 
+.SH "AUTHORS"
+.LP 
+The routel script was written by Stephen R. van den Berg <srb@cuci.nl>, 1999/04/18 and donated to the public domain.
+.br
+This manual page was written by Andreas Henriksson  <andreas@fatal.se>, for the Debian GNU/Linux system.
+.SH "SEE ALSO"
+.LP 
+ip(8)

commit c42376a6d94d8fc5853d5d8a02b894856ed73cc8
Author: Daniel Silverstone <daniel.silverstone@ubuntu.com>
Date:   Fri Oct 19 13:32:24 2007 +0200

    Avoid infinite loop in ip addr flush.
    
    Fix "ip addr flush" the same way "ip neigh flush" was previously fixed,
    by bailing out if the flush hasn't completed after MAX_ROUNDS (10) tries.

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 59c71c8..373312f 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -35,6 +35,8 @@
 #include "ll_map.h"
 #include "ip_common.h"
 
+#define MAX_ROUNDS 10
+
 static struct
 {
 	int ifindex;
@@ -684,7 +686,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		for (;;) {
+		while (round < MAX_ROUNDS) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -711,6 +713,8 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
+		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		return 1;
 	}
 
 	if (filter.family != AF_PACKET) {




