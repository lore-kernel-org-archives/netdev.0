From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] b44: allow ethtool get_settings when down
Date: Mon, 29 Nov 2004 09:45:23 -0800
Message-ID: <20041129094523.3185c64c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The FC and Suse startup scripts use ethtool to check for link present. This has 
problems on my laptop with Broadcom because it quieries settings before
bringing link up. The problem is driver returns EAGAIN when queried for
settings but not up. Just go ahead and return values anyway, the supported and link
state values will be correct, speed will end up being 10BaseT/Half which is a
reasonable default.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	2004-11-29 09:41:27 -08:00
+++ b/drivers/net/b44.c	2004-11-29 09:41:27 -08:00
@@ -1487,8 +1487,6 @@
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!(bp->flags & B44_FLAG_INIT_COMPLETE))
-		return -EAGAIN;
 	cmd->supported = (SUPPORTED_Autoneg);
 	cmd->supported |= (SUPPORTED_100baseT_Half |
 			  SUPPORTED_100baseT_Full |
