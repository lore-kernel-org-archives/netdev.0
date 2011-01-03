From: hayeswang <hayeswang@realtek.com>
Subject: RE: [net-next-2.6 08/08] r8169: more 8168dp support.
Date: Mon, 3 Jan 2011 20:50:03 +0800
Message-ID: <C4B63551EF6C4B57BB20D6922F78AA12@realtek.com.tw>
References: <20110102233751.GI5780@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'Ben Hutchings' <benh@debian.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realtek.com.tw ([60.250.210.236]:3931 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab1ACMuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 07:50:06 -0500
In-Reply-To: <20110102233751.GI5780@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Monday, January 03, 2011 7:38 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Hayeswang; Ben Hutchings
> Subject: [net-next-2.6 08/08] r8169: more 8168dp support.
> 
> Adapted from version 8.019.00 of Realtek's r8168 driver
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes <hayeswang@realtek.com>
> ---
> @@ -3038,8 +3104,10 @@ static void __devexit 
> rtl8169_remove_one(struct pci_dev *pdev)
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_28)) {
>  		rtl8168_driver_stop(tp);
> +	}
>  
>  	cancel_delayed_work_sync(&tp->task);
>  
> @@ -3122,11 +3190,19 @@ err_pm_runtime_put:
>  	goto out;
>  }
>  
> -static void rtl8169_hw_reset(void __iomem *ioaddr)
> +static void rtl8169_hw_reset(struct rtl8169_private *tp)
>  {
> +	void __iomem *ioaddr = tp->mmio_addr;
> +
>  	/* Disable interrupts */
>  	rtl8169_irq_mask_and_ack(ioaddr);
>  
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {

This check should include RTL_GIGA_MAC_VER_27.

> +		while (RTL_R8(TxPoll) & NPQ)
> +			udelay(20);
> +
> +	}
> +
>  	/* Reset the chipset */
>  	RTL_W8(ChipCmd, CmdReset);
>  

After the reset, there are something to do for RTL_GIGA_MAC_VER_27. You may
check the soure code of realtek. Find "rtl8168_nic_reset".
 
Best Regards,
Hayes


