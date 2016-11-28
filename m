From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: ipvlan: Add the sanity check for ipvlan mode
Date: Mon, 28 Nov 2016 21:23:55 +0800
Message-ID: <1480339435-15551-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg292.qq.com ([113.108.11.231]:32827 "EHLO smtpbg292.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754514AbcK1NZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The ipvlan mode variable "nval" is from userspace, so the ipvlan codes
should check if the mode variable "nval" is valid.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ab90b22..537b5a9 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -65,6 +65,9 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
 	struct net_device *mdev = port->dev;
 	int err = 0;
 
+	if (nval >= IPVLAN_MODE_MAX)
+		return -EINVAL;
+
 	ASSERT_RTNL();
 	if (port->mode != nval) {
 		if (nval == IPVLAN_MODE_L3S) {
-- 
1.9.1
