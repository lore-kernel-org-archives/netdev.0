From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN]: Prevent nesting macvlan devices
Date: Thu, 10 Jan 2008 16:32:38 +0100
Message-ID: <47863A96.5080708@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000306010608010103090904"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57258 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562AbYAJPhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:37:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000306010608010103090904
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000306010608010103090904
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[MACVLAN]: Prevent nesting macvlan devices

Don't allow to nest macvlan devices since it will cause lockdep warnings and
isn't really useful for anything.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 80a76fbde679793a17482a3dd842386801fca66b
tree 07f67e78ac0ae505a5de81e7e770a1b7d597f120
parent 4d14fded63dcaf9d5dcf78e2a8ea3f5de2c29eb9
author Patrick McHardy <kaber@trash.net> Thu, 10 Jan 2008 16:25:01 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 10 Jan 2008 16:25:01 +0100

 drivers/net/macvlan.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2e4bcd5..e8dc2f4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -384,6 +384,13 @@ static int macvlan_newlink(struct net_device *dev,
 	if (lowerdev == NULL)
 		return -ENODEV;
 
+	/* Don't allow macvlans on top of other macvlans - its not really
+	 * wrong, but lockdep can't handle it and its not useful for anything
+	 * you couldn't do directly on top of the real device.
+	 */
+	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops)
+		return -ENODEV;
+
 	if (!tb[IFLA_MTU])
 		dev->mtu = lowerdev->mtu;
 	else if (dev->mtu > lowerdev->mtu)

--------------000306010608010103090904--
