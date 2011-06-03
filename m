From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] iproute: Ignore all output fields of ip route get for route add
Date: Fri, 3 Jun 2011 10:39:18 +0200
Message-ID: <20110603083918.GA15883@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41250 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab1FCIjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 04:39:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My vpnc-connect script broke in a kernel release because the new
kernel started returning the ipid in ip cache get. The script
would do ip route get, modify the route and then feed it back
to ip route add. But ip route add couldn't parse ipid ..

Make route add skip all status fields output by ip cache get

In theory they could be fed to the kernel too, but that's likely
not very useful (and I'm not fully sure if the kernel would
even use them)

Signed-off-by: Andi Kleen <ak@linux.intel.com>

diff --git a/ip/iproute.c b/ip/iproute.c
index 2fef35b..8b7421e 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -936,6 +936,17 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			   strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
 			d = *argv;
+		/* Ignore everything else printed by ip route get. */
+		} else if (strcmp(*argv, "ipid") == 0 ||
+			   strcmp(*argv, "ts") == 0 ||
+			   strcmp(*argv, "tsage") == 0 ||
+			   strcmp(*argv, "age") == 0 ||
+			   strcmp(*argv, "used") == 0 ||
+			   strcmp(*argv, "users") == 0 ||
+			   strcmp(*argv, "error") == 0 ||
+			   strcmp(*argv, "cache") == 0 ||
+			   strcmp(*argv, "expires") == 0) {
+			NEXT_ARG();
 		} else {
 			int type;
 			inet_prefix dst;
-- 
ak@linux.intel.com -- Speaking for myself only.
