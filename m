From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: avoid errors from double-installing manpages
Date: Fri, 9 Nov 2012 16:42:41 +0100
Message-ID: <20121109154241.GA29156@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:51608 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754437Ab2KIQB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 11:01:27 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 665BEEB711
	for <netdev@vger.kernel.org>; Fri,  9 Nov 2012 16:42:14 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three manpages in man8 are listed twice in MAN8PAGES (both directly and
in TARGETS) which causes the install command to spit our a couple of
warnings as below and exiting with non-zero exit code....

make[3]: Entering directory `/tmp/buildd/iproute-20121001/man/man8'
install -m 0755 -d /tmp/buildd/iproute-20121001/debian/tmp/usr/share/man/man8
install -m 0644 ip-address.8 ip-link.8 ip-route.8 ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 tc.8 tc-bfifo.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 ip-address.8 ip-addrlabel.8 ip-l2tp.8 ip-link.8 ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 ip-netns.8 ip-ntable.8 ip-route.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 /tmp/buildd/iproute-20121001/debian/tmp/usr/share/man/man8
install: will not overwrite just-created `/tmp/buildd/iproute-20121001/debian/tmp/usr/share/man/man8/ip-address.8' with `ip-address.8'
install: will not overwrite just-created `/tmp/buildd/iproute-20121001/debian/tmp/usr/share/man/man8/ip-link.8' with `ip-link.8'
install: will not overwrite just-created `/tmp/buildd/iproute-20121001/debian/tmp/usr/share/man/man8/ip-route.8' with `ip-route.8'
make[3]: *** [install] Error 1
make[3]: Leaving directory `/tmp/buildd/iproute-20121001/man/man8'
make[2]: *** [install] Error 2
make[2]: Leaving directory `/tmp/buildd/iproute-20121001/man'

Signed-off-by: Andreas Henriksson <andreas@fatal.se>


diff --git a/man/man8/Makefile b/man/man8/Makefile
index aaf1729..4bad9d6 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -1,19 +1,19 @@
 TARGETS = ip-address.8 ip-link.8 ip-route.8
 
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc.8 tc-bfifo.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
 	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 \
 	tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
 	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
-	ip-address.8 ip-addrlabel.8 ip-l2tp.8 ip-link.8 \
+	ip-addrlabel.8 ip-l2tp.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
-	ip-netns.8 ip-ntable.8 ip-route.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
+	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
 	ip-tcp_metrics.8
 
 all: $(TARGETS)
 
 ip-address.8: ip-address.8.in
 	sed "s|@SYSCONFDIR@|$(CONFDIR)|g" $< > $@
 
 ip-link.8: ip-link.8.in
