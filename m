From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 04:00:39 +0400
Message-ID: <20080922000039.GA1878@2ka.mipt.ru>
References: <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921124332.67ddc13a@infradead.org> <20080921202057.GB25052@2ka.mipt.ru> <20080921132753.5689b564@infradead.org> <20080921205706.GA24545@2ka.mipt.ru> <20080921140203.4698a2ee@infradead.org> <20080921210554.GA2135@2ka.mipt.ru> <1222039667.6782.125.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Marcel Holtmann <holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1222039667.6782.125.camel@californication>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2008 at 01:27:47AM +0200, Marcel Holtmann (holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org) wrote:
> as Arjan and Alan pointed out already, WARN_ON_ONCE is enough and I
> agree with them. Just to make this perfectly clear, this is with my
> community hat on.
> 
> Please send a proper patch with a simple WARN_ON_ONCE and I am happy to
> sign off on it.

I really do not care about if there is warning at all, I just want that
bug to be fixed. And a we can see, something started to change, and that's
probably a good sign. I glad there is a result. I will check d3 states
tomorrow. Attached patch if you think it is yet needed.

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 19a401c..637dc05 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -3174,16 +3174,18 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
 	if (inta & IPW2100_INTA_FATAL_ERROR) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Fatal interrupt. Scheduling firmware restart.\n");
+
 		priv->inta_other++;
 		write_register(dev, IPW_REG_INTA, IPW2100_INTA_FATAL_ERROR);
 
 		read_nic_dword(dev, IPW_NIC_FATAL_ERROR, &priv->fatal_error);
-		IPW_DEBUG_INFO("%s: Fatal error value: 0x%08X\n",
-			       priv->net_dev->name, priv->fatal_error);
