From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] bonding: enable netpoll without checking link status
Date: Mon, 14 Mar 2011 18:05:21 -0400
Message-ID: <1300140321-12056-1-git-send-email-andy@greyhouse.net>
Cc: WANG Cong <amwang@redhat.com>, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754101Ab1CNWEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 18:04:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only slaves that are up should transmit netpoll frames, so there is no
need to check to see if a slave is up before enabling netpoll on it.
This resolves a reported failure on active-backup bonds where a slave
interface is down when netpoll was enabled.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Tested-by: WANG Cong <amwang@redhat.com>

---
 drivers/net/bonding/bond_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7b7ca97..b14c377 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1352,8 +1352,6 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
 
 	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
-		if (!IS_UP(slave->dev))
-			continue;
 		err = slave_enable_netpoll(slave);
 		if (err) {
 			__bond_netpoll_cleanup(bond);
