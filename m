From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.17-rc1] Fix RtNetlink ENCODE security permissions
Date: Fri, 14 Apr 2006 10:47:26 -0700
Message-ID: <20060414174726.GA24421@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:58788 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1751326AbWDNRr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 13:47:28 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi John,

	I've just realised that the RtNetlink code does not check the
permission for SIOCGIWENCODE and SIOCGIWENCODEEXT, which means that
any user can read the encryption keys. The fix is trivial and should
go in 2.6.17 alonside the two other patch I sent you last week.
	Fully tested on 2.6.17-rc1.

	Have fun...

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/net/core/wireless.j1.c linux/net/core/wireless.c
--- linux/net/core/wireless.j1.c	2006-04-13 18:29:49.000000000 -0700
+++ linux/net/core/wireless.c	2006-04-13 18:35:59.000000000 -0700
@@ -1726,6 +1726,14 @@ int wireless_rtnetlink_get(struct net_de
 	if(!IW_IS_GET(request->cmd))
 		return -EOPNOTSUPP;
 
+	/* If command is `get the encoding parameters', check if
+	 * the user has the right to do it */
+	if (request->cmd == SIOCGIWENCODE ||
+	    request->cmd == SIOCGIWENCODEEXT) {
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+	}
+
 	/* Special cases */
 	if(request->cmd == SIOCGIWSTATS)
 		/* Get Wireless Stats */

