From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH v4] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Tue, 15 Jul 2014 14:24:13 +0530
Message-ID: <53C4EC35.1080205@gmail.com>
References: <1405413820-28739-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:56020 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758136AbaGOIz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 04:55:26 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so6952312pab.4
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 01:55:26 -0700 (PDT)
In-Reply-To: <1405413820-28739-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 02:13 PM, Sonic Zhang wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>
>
> Ethernet RX DMA buffers are polled in NAPI work queue other than received
> directly in DMA RX interrupt handler.
>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>
> ---
> v2-changes:
> - avoid test NAPI_STATE_NPSVC bit in net device driver
>
> v3-changes:
> - use tabs while indenting the code
>
> v4-changes:
> - unconditionally compete the NAPI poll and re-enable the MAC_RX IRQ
>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> ---
>   drivers/net/ethernet/adi/bfin_mac.c | 79 +++++++++++++++++++++++--------------
>   drivers/net/ethernet/adi/bfin_mac.h |  1 +
>   2 files changed, 50 insertions(+), 30 deletions(-)
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index 7ae74d4..b838e81 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -1218,11 +1218,13 @@ out:
>   #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
>   	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
>   
> -static void bfin_mac_rx(struct net_device *dev)
> +static void bfin_mac_rx(struct napi_struct *napi, int budget)
>   {
> +	struct bfin_mac_local *lp = container_of(napi,
> +				struct bfin_mac_local, napi);

should match open parenthesis

struct bfin_mac_local *lp = container_of(napi,
					 struct bfin_mac_local,
					 napi);

> +	struct net_device *dev = lp->ndev;
>   	

-- 
Regards,
Varka Bhadram.
