From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v1 1/2] amd-xgbe: Do not clear interrupt indicator
Date: Wed, 03 Dec 2014 14:34:35 +0300
Message-ID: <547EF54B.1050308@cogentembedded.com>
References: <20141203001642.17582.32777.stgit@tlendack-t1.amdoffice.net> <20141203001648.17582.48766.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:59816 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbaLCLei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 06:34:38 -0500
Received: by mail-la0-f46.google.com with SMTP id q1so7541764lam.33
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 03:34:37 -0800 (PST)
In-Reply-To: <20141203001648.17582.48766.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/3/2014 3:16 AM, Tom Lendacky wrote:

> The interrupt value within the xgbe_ring_data structure is used as an
> indicator of which Rx descriptor should have the INTE bit set to
> generate an interrupt when that Rx descriptor is used.  This bit was
> mistakenly cleared in the xgbe_unmap_rdata function, effectively

    Not xgbe_unmap_skb() (as seems to follow from the patch)?

> nullifying the ethtool rx-frames support.

> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    1 -
>   1 file changed, 1 deletion(-)

> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
> index 6fc5da0..43b7d2e 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
> @@ -356,7 +356,6 @@ static void xgbe_unmap_skb(struct xgbe_prv_data *pdata,
>
>   	rdata->tso_header = 0;
>   	rdata->len = 0;
> -	rdata->interrupt = 0;
>   	rdata->mapped_as_page = 0;
>
>   	if (rdata->state_saved) {

WBR, Sergei
