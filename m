From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 3/3] r8169: support new chips of RTL8111F
Date: Wed, 31 Aug 2011 21:13:58 +0200
Message-ID: <20110831191358.GB24634@electric-eye.fr.zoreil.com>
References: <1314807479-1552-1-git-send-email-hayeswang@realtek.com> <1314807479-1552-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41917 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab1HaTc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 15:32:26 -0400
Content-Disposition: inline
In-Reply-To: <1314807479-1552-3-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 68f1e2f..c04fbc0 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -4476,6 +4602,49 @@ static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
>  	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
>  }
>  
> +static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
[...]
> +	RTL_W8(MaxTxPacketSize, 0x27);

Hmmm...

$ grep MaxTxPacketSize drivers/net/r8169.c
	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, 0x27);
	RTL_W8(MaxTxPacketSize, TxPacketMax);
	RTL_W8(MaxTxPacketSize, TxPacketMax);

Is the 0x27 value still in units of 128 bytes ?

Could it be TxPacketMax as everywhere else in the driver instead of 0x27 ?

-- 
Ueimor
