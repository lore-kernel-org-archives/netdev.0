From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: [PATCH 2.6] airo.c set_bit bug
Date: Thu, 22 Jul 2004 17:21:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723002114.GA11815@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Javier Achirica <achirica@ttd.net>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi Javier,

	Managed to find a bug in the usage of set_bit/clear_bit in the
airo driver. I'm not sure if I caught all occurence of this pattern,
and not sure about exact consequences of the bug, but we might as well
fix it...
	Patch below...

	Have fun...

	Jean

--------------------------------------------------------

--- linux/drivers/net/wireless/airo.j1.c	Thu Jul 22 15:27:48 2004
+++ linux/drivers/net/wireless/airo.c	Thu Jul 22 15:29:11 2004
@@ -1808,7 +1808,8 @@ static int writeConfigRid(struct airo_in
 	if (!test_bit (FLAG_COMMIT, &ai->flags))
 		return SUCCESS;
 
-	clear_bit (FLAG_COMMIT | FLAG_RESET, &ai->flags);
+	clear_bit (FLAG_COMMIT, &ai->flags);
+	clear_bit (FLAG_RESET, &ai->flags);
 	checkThrottle(ai);
 	cfgr = ai->config;
 
@@ -6158,7 +6159,8 @@ static int airo_set_txpow(struct net_dev
 	readCapabilityRid(local, &cap_rid);
 
 	if (vwrq->disabled) {
-		set_bit (FLAG_RADIO_OFF | FLAG_COMMIT, &local->flags);
+		set_bit (FLAG_RADIO_OFF, &local->flags);
+		set_bit (FLAG_COMMIT, &local->flags);
 		return -EINPROGRESS;		/* Call commit handler */
 	}
 	if (vwrq->flags != IW_TXPOW_MWATT) {
