From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/7] [lmc]: Use netif_carrier_* instead of IFF_RUNNING
Date: Mon, 28 Mar 2005 02:08:49 +0200
Message-ID: <20050328000849.GR3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:15:07+02:00 tgraf@suug.ch 
#   [lmc]: Use netif_carrier_* instead of IFF_RUNNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# drivers/net/wan/lmc/lmc_main.c
#   2005/03/28 00:14:55+02:00 tgraf@suug.ch +2 -6
#   [lmc]: Use netif_carrier_* instead of IFF_RUNNING
# 
diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
--- a/drivers/net/wan/lmc/lmc_main.c	2005-03-28 01:07:55 +02:00
+++ b/drivers/net/wan/lmc/lmc_main.c	2005-03-28 01:07:55 +02:00
@@ -723,7 +723,7 @@
         /* lmc_reset (sc); Why reset??? The link can go down ok */
 
         /* Inform the world that link has been lost */
-        dev->flags &= ~IFF_RUNNING;
+	netif_carrier_off(dev);
     }
 
     /*
@@ -736,7 +736,7 @@
          /* lmc_reset (sc); Again why reset??? */
 
          /* Inform the world that link protocol is back up. */
-         dev->flags |= IFF_RUNNING;
+	 netif_carrier_on(dev);
 
          /* Now we have to tell the syncppp that we had an outage
           * and that it should deal.  Calling sppp_reopen here
@@ -1168,8 +1168,6 @@
     sc->lmc_media->set_link_status (sc, 1);
     sc->lmc_media->set_status (sc, NULL);
 
-    //dev->flags |= IFF_RUNNING;
-    
     netif_wake_queue(dev);
 
     sc->lmc_txfull = 0;
@@ -1232,8 +1230,6 @@
     csr6 &= ~LMC_DEC_ST;		/* Turn off the Transmission bit */
     csr6 &= ~LMC_DEC_SR;		/* Turn off the Receive bit */
     LMC_CSR_WRITE (sc, csr_command, csr6);
-
-    dev->flags &= ~IFF_RUNNING;
 
     sc->stats.rx_missed_errors +=
         LMC_CSR_READ (sc, csr_missed_frames) & 0xffff;
