From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, net-next] r8169: On RTL 8101 series bit SYSErr is
 reserved.
Date: Mon, 24 Aug 2015 11:38:18 -0700 (PDT)
Message-ID: <20150824.113818.620937362100781821.davem@davemloft.net>
References: <1440439973-7400-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184AbbHXSiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 14:38:20 -0400
In-Reply-To: <1440439973-7400-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Mon, 24 Aug 2015 21:12:53 +0300

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 5693e65..32d2072 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -8256,6 +8256,14 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
>  	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));*/
>  	switch (tp->mac_version) {
> +	case RTL_GIGA_MAC_VER_07:
> +	case RTL_GIGA_MAC_VER_08:
> +	case RTL_GIGA_MAC_VER_09:
> +	case RTL_GIGA_MAC_VER_10:
> +	case RTL_GIGA_MAC_VER_13:
> +	case RTL_GIGA_MAC_VER_16:
> +		pci_write_config_word(pdev, PCI_COMMAND, ~PCI_COMMAND_SERR); 

You're writing all sorts of bits you definitely don't want to set here.

Furthermore, there is no need to clear a bit that shouldn't be set
in the first place.

Your patches are really full of major errors, and unsuitable for
upstream.

Yes, all of them.

So please stop posting your r8169 changes here, because if you don't
care if your patches get included or not, then you should not be
posting them here.  This isn't a place to just dump ramdom patches,
sorry.
