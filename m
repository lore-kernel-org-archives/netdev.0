From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/6] cxgb4: Pass in a Congestion Channel Map
 to t4_sge_alloc_rxq()
Date: Mon, 04 May 2015 23:25:05 +0300
Message-ID: <5547D5A1.9050208@cogentembedded.com>
References: <1430756900-6086-1-git-send-email-hariprasad@chelsio.com> <1430756900-6086-4-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36128 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbEDUZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:25:10 -0400
Received: by lagv1 with SMTP id v1so112614359lag.3
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 13:25:08 -0700 (PDT)
In-Reply-To: <1430756900-6086-4-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/04/2015 07:28 PM, Hariprasad Shenai wrote:

> Passes a Congestion Channel Map to t4_sge_alloc_rxq()
> for the Ethernet RX Queues based on the MPS Buffer Group Map
> of the TX Channel rather than just the TX Channel Map.
> Also, in t4_sge_alloc_rxq() for T5, setting up the
> Congestion Manager values of the new RX Ethernet Queue is
> done by firmware now.

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/sge.c       | 35 ++++++++++++++++++++++++++
>   drivers/net/ethernet/chelsio/cxgb4/t4_values.h |  9 +++++++
>   drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h  |  1 +
>   3 files changed, 45 insertions(+)

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> index 7547a9c..757e0ab 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> @@ -2551,6 +2551,41 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
[...]
> +		ret = t4_set_params(adap, adap->mbox, adap->fn, 0, 1,
> +				    &param, &val);
> +		if (ret)
> +			dev_warn(adap->pdev_dev, "Failed to set Congestion"
> +				 " Manager Context for Ingress Queue %d: %d\n",

    There's no need to break the long kernel messages, actually it's even 
frowned upon as it makes grepping more complex.

[...]

WBR, Sergei
