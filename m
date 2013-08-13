From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: remember WOL preferences on driver load
Date: Tue, 13 Aug 2013 23:28:43 +0200
Message-ID: <20130813212843.GB5635@electric-eye.fr.zoreil.com>
References: <1376425145-30142-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Hayes Wang <hayeswang@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48985 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759272Ab3HMV2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:28:50 -0400
Content-Disposition: inline
In-Reply-To: <1376425145-30142-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
> Do not clear Broadcast/Multicast/Unicast Wake Flag or LanWake in
> Config5. This is necessary to preserve WOL state when the driver is
> loaded.

Ok, it makes sense.

> The r8168 vendor driver used to write to both Config1 and Config5, but
> in recent versions, this is commented out. Here we keep writing PMEnable
> to Config1 because there may be older chips where PMEnable is not sticky.

<sneak regression paranoia>
Please include the bits you want to keep in the "&" mask.
</sneak regression paranoia>

Hayes, any advice (especially regarding Config5) ?

[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 28af01c..7bdf322 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7093,7 +7093,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	RTL_W8(Cfg9346, Cfg9346_Unlock);
>  	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
> -	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
>  	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
>  		tp->features |= RTL_FEATURE_WOL;
>  	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
> -- 
> 1.8.3.4
