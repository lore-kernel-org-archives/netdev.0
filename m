From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] Fix net/hsr/hsr_device to check for freed skb buffer.
Date: Thu, 20 Apr 2017 13:15:43 +0300
Message-ID: <f9b4402d-3af8-ae34-c8c8-bea1ff72a844@cogentembedded.com>
References: <0102015b8a4332ea-1e523746-5fd0-48d9-9045-d9de973fcd1a-000000@eu-west-1.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Heise <mail@pheise.de>, Arvid Brodin <arvid.brodin@alten.se>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34875 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031410AbdDTKPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 06:15:44 -0400
Received: by mail-lf0-f41.google.com with SMTP id 75so26181702lfs.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 03:15:43 -0700 (PDT)
In-Reply-To: <0102015b8a4332ea-1e523746-5fd0-48d9-9045-d9de973fcd1a-000000@eu-west-1.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 4/20/2017 10:28 AM, Peter Heise wrote:

> Fixed an unchecked call of skb_put_padto. Return value was ignored
> before, however, skb_put_padto frees skb buffer in case of error.
>
> As reported by Dan Carpenter on kernel-janitors.
>
> Signed-off-by: Peter Heise <mail@pheise.de>
> ---
>  net/hsr/hsr_device.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
> index c73160fb11e7..22d693f213be 100644
> --- a/net/hsr/hsr_device.c
> +++ b/net/hsr/hsr_device.c
> @@ -314,7 +314,8 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
>  	hsr_sp = (typeof(hsr_sp)) skb_put(skb, sizeof(struct hsr_sup_payload));
>  	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
>
> -	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
> +	if(skb_put_padto(skb, ETH_ZLEN + HSR_HLEN))

    Need a space after *if*. Pleae run your patches thru scripts/checkpatch.pl 
before sending.

> +		return;
>
>  	hsr_forward_skb(skb, master);
>  	return;

MBR, Seregi
