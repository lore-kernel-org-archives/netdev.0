From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Wed, 14 Aug 2013 00:20:38 +0200
Message-ID: <20130813222038.GC5635@electric-eye.fr.zoreil.com>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49138 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759004Ab3HMWUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:20:48 -0400
Content-Disposition: inline
In-Reply-To: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index b5eb419..28af01c 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1897,12 +1897,17 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
[...]
> -	memcpy_fromio(p, tp->mmio_addr, regs->len);
> +	for (i = 0; i < regs->len - 4; i += 4)
> +		memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);

regs->len is u32. regs->len - 4 should not underflow on normal situation but
it's a bit sloppy.

-- 
Ueimor
