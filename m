From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 11 Jun 2008 22:30:19 -0400
Message-ID: <20080612023019.GA25798@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755036AbYFLCad@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


WARNING: my incoming email has been inaccessible for the past ~18
hours, so if it appears I missed something recently, I probably did...
 ...(but have backed up on an equally inaccessible backup-MX machine)

Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/fec_mpc52xx.c |    2 +-
 drivers/net/ipg.c         |    4 ++--
 drivers/net/r6040.c       |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

Christophe Jaillet (1):
      drivers/net/r6040.c: correct bad use of round_jiffies()

Roel Kluin (2):
      ipg: fix receivemode IPG_RM_RECEIVEMULTICAST{,HASH} in ipg_nic_set_multicast_list()
      fec_mpc52xx: MPC52xx_MESSAGES_DEFAULT: 2nd NETIF_MSG_IFDOWN => IFUP

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 5f9c42e..329edd9 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -78,7 +78,7 @@ module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0);
 MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
 
 #define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
-		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
+		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP)
 static int debug = -1;	/* the above default */
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "debugging messages level");
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 9b358f6..679a082 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -577,12 +577,12 @@ static void ipg_nic_set_multicast_list(struct net_device *dev)
 		/* NIC to be configured in promiscuous mode. */
 		receivemode = IPG_RM_RECEIVEALLFRAMES;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-		   (dev->flags & IFF_MULTICAST &
+		   ((dev->flags & IFF_MULTICAST) &&
 		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
 		/* NIC to be configured to receive all multicast
 		 * frames. */
 		receivemode |= IPG_RM_RECEIVEMULTICAST;
-	} else if (dev->flags & IFF_MULTICAST & (dev->mc_count > 0)) {
+	} else if ((dev->flags & IFF_MULTICAST) && (dev->mc_count > 0)) {
 		/* NIC to be configured to receive selected
 		 * multicast addresses. */
 		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 169edc1..858b191 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -733,7 +733,7 @@ static void r6040_timer(unsigned long data)
 	}
 
 	/* Timer active again */
-	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
+	mod_timer(&lp->timer, round_jiffies(jiffies + HZ));
 }
 
 /* Read/set MAC address routines */
