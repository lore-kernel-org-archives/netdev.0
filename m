From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: Re: [PATCH 2.6.0-test4][NET] sk_mca.c: fix linker error
Date: 23 Aug 2003 19:15:15 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061646315.1141.26.camel@lima.royalchallenge.com>
References: <1061644938.2787.22.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
In-Reply-To: <1061644938.2787.22.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-08-23 at 18:52, Vinay K Nallamothu wrote:
> Hi,
> 
> This patch fixes the following linker error due to a typo:
> 
> *** Warning: "spin_lock_irqrestore" [drivers/net/sk_mca.ko] undefined!
Oops. missed out few more. Here is the updated patch.

--- linux-2.6.0-test4/drivers/net/sk_mca.c	2003-07-28 10:43:57.000000000 +0530
+++ linux-2.6.0-test4-nvk/drivers/net/sk_mca.c	2003-08-23 19:12:16.000000000 +0530
@@ -280,7 +280,7 @@
 
 	/* reenable interrupts */
 
-	spin_lock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 /* get LANCE register */
@@ -319,7 +319,7 @@
 
 	/* reenable interrupts */
 
-	spin_lock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->lock, flags);
 
 	return res;
 }
@@ -993,7 +993,7 @@
 	if (priv->txbusy == 0)
 		SetLANCE(dev, LANCE_CSR0, CSR0_INEA | CSR0_TDMD);
 
-	spin_lock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->lock, flags);
 
       tx_done:
 
