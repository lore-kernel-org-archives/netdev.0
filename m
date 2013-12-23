From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/6] bnx2x: no error when RSS configuration fails
Date: Tue, 24 Dec 2013 01:36:37 +0300
Message-ID: <52B8BAF5.7070904@cogentembedded.com>
References: <1387824283-15687-1-git-send-email-yuvalmin@broadcom.com> <1387824283-15687-5-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:55365 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574Ab3LWVgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 16:36:35 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so2496811lbi.2
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 13:36:34 -0800 (PST)
In-Reply-To: <1387824283-15687-5-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/23/2013 09:44 PM, Yuval Mintz wrote:

> It's possible for VMs with older versions of bnx2x to run over a hypervisor
> with latest driver. If a VF in such a VM does not support RSS configuration,
> the PF driver in the hypervisor will print an error message to system logs.

> This changes the error message into a debug message, as this is very likely
> a false alarm for an older VF (i.e., VF manages to work properly; PF simply
> cannot configure the additional queues for it).

> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> index efa8a15..c7aaf5b 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> @@ -800,14 +800,18 @@ int bnx2x_vfpf_config_rss(struct bnx2x *bp,
>   	}
>
>   	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
> -		BNX2X_ERR("failed to send rss message to PF over Vf PF channel %d\n",
> -			  resp->hdr.status);
> -		rc = -EINVAL;
> +		/* Since older drivers don't support this feature (and VF has
> +		 * no way of knowing other than failing this), don't propogate

    Sorry for the grammar nitpicking but it's "propAgate".

> +		 * an error in this case.
> +		 */
> +		DP(BNX2X_MSG_IOV,
> +		   "Failed to send rss message to PF over VF-PF channel [%d]\n",
> +		   resp->hdr.status);
>   	}

WBR, Sergei
