From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: [PATCH] Plip ioctl bug
Date: Fri, 11 Jun 2004 16:11:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611231154.GA21485@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Nimrod Zimerman <zimerman@mailandnews.com>,
        Niibe Yutaka <gniibe@mri.co.jp>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi all,

	Plip should verify that it got the proper ioctl to avoid false
positive. User reported that plip suddenly was gaining wireless
capability ;-)
	Have fun...

	Jean

Signed-off-by: $me
------------------------------------------

diff -u -p linux/drivers/net/plip.b0.c linux/drivers/net/plip.c
--- linux/drivers/net/plip.b0.c	Fri Jun 11 16:00:13 2004
+++ linux/drivers/net/plip.c	Fri Jun 11 16:03:14 2004
@@ -1219,6 +1219,11 @@ plip_ioctl(struct net_device *dev, struc
 	struct net_local *nl = netdev_priv(dev);
 	struct plipconf *pc = (struct plipconf *) &rq->ifr_data;
 
+	/* Respond only to our IOCTL, ignore other IOCTLs, such as
+	 * Ethtool and Wireless Extensions. Jean II */
+	if(cmd != SIOCDEVPLIP)
+		return -EOPNOTSUPP;
+
 	switch(pc->pcmd) {
 	case PLIP_GET_TIMEOUT:
 		pc->trigger = nl->trigger;
