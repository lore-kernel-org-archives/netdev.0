From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH]  add pcibios_enable_device() return value check
Date: Thu, 28 Feb 2008 22:54:52 +0100
Message-ID: <200802282254.52426.mb@bu3sch.de>
References: <20080228221538.058d1f40.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:45149 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755075AbYB1VzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:55:21 -0500
In-Reply-To: <20080228221538.058d1f40.yoichi_yuasa@tripeaks.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 February 2008 14:15:38 Yoichi Yuasa wrote:
> This patch has added pcibios_enable_device() return value check.
> 
> Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
> 
> diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/ssb/driver_pcicore.c linux/drivers/ssb/driver_pcicore.c
> --- linux-orig/drivers/ssb/driver_pcicore.c	2008-02-26 15:51:13.146734949 +0900
> +++ linux/drivers/ssb/driver_pcicore.c	2008-02-26 15:54:29.257910690 +0900
> @@ -111,7 +111,8 @@ static void __init ssb_fixup_pcibridge(s
>  
>  	/* Enable PCI bridge bus mastering and memory space */
>  	pci_set_master(dev);
> -	pcibios_enable_device(dev, ~0);
> +	if (pcibios_enable_device(dev, ~0) < 0)
> +		return;

I'm not sure if we really want to silently fail here.
Please add this:
		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");

>  	/* Enable PCI bridge BAR1 prefetch and burst */
>  	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);

-- 
Greetings Michael.
