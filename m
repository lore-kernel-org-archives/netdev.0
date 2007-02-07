From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix for oops on resume
Date: Wed, 07 Feb 2007 07:50:40 -0600
Message-ID: <45C9D930.5010307@lwfinger.net>
References: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger@lwfinger.net>	 <1170850549.6798.22.camel@johannes.berg>  <45C9D2E1.7040906@lwfinger.net> <1170855150.6798.38.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1170855150.6798.38.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-02-07 at 07:23 -0600, Larry Finger wrote:
> 
>> As you suggested earlier, a slow clock setting in the bcm43xx device may be the cause of this
>> difficulty. If my laptop would suspend/resume correctly, then I could test various fixes based on
>> that hypothesis. 
> 
> Mine does suspend, but I don't see the problem...

Could you please apply this patch and tell me what gets printed after you resume, and whether you
did a suspend to RAM or disk?

I welcome the results of this test from anyone whose system will suspend/resume. Please also note if
any further action is needed to get wireless communication re-established.

Thanks,

Larry


==========

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2401,6 +2401,7 @@ static int bcm43xx_chip_init(struct bcm4
 		}
 		udelay(10);
 	}
+	dprintk(KERN_INFO PFX "It took %d tries to set IRQ_READY\n", i);
 	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */

 	value16 = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,

-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
