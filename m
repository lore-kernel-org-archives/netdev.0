From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcmfmac: Ensure pointer correctly set if skb data
 location changes
Date: Mon, 24 Apr 2017 13:10:50 +0200
Message-ID: <bb374f51-f0c7-d315-6a82-11400e71625a@broadcom.com>
References: <20170424105219.18797-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: James Hughes <james.hughes@raspberrypi.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38115 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1046498AbdDXLMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 07:12:48 -0400
Received: by mail-it0-f46.google.com with SMTP id e132so51794926ite.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 04:12:47 -0700 (PDT)
In-Reply-To: <20170424105219.18797-1-james.hughes@raspberrypi.org>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/2017 12:52 PM, James Hughes wrote:
> The incoming skb header may be resized if header space is
> insufficient, which might change the data adddress in the skb.
> Ensure that a cached pointer to that data is correctly set by
> moving assignment to after any possible changes.

Thanks, James

Minor nit below...

You may add my acknowledgement:

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---
>   drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c

[...]

> @@ -229,6 +229,8 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
>   		}
>   	}
>   
> +	eh = (struct ethhdr *)(skb->data);
> +

Please move after the length validation below.

Regards,
Arend

>   	/* validate length for ether packet */
>   	if (skb->len < sizeof(*eh)) {
>   		ret = -EINVAL;
> 
