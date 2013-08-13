From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/3] net/usb/r8152: enable tx checksum
Date: Tue, 13 Aug 2013 18:39:36 +0400
Message-ID: <520A4528.6020609@cogentembedded.com>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com> <1376378913-879-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:56599 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab3HMOjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:39:33 -0400
Received: by mail-lb0-f182.google.com with SMTP id v20so5952654lbc.27
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 07:39:32 -0700 (PDT)
In-Reply-To: <1376378913-879-2-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/13/2013 11:28 AM, Hayes Wang wrote:

> Enable tx checksum.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>   drivers/net/usb/r8152.c | 63 +++++++++++++++++++++++++++++++++++++++++++++----
>   1 file changed, 58 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index c6c5aa2..5d9d949 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> @@ -964,6 +971,51 @@ err1:
>   	return -ENOMEM;
>   }
>
> +static void
> +r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
> +{
[...]
> +		if (ip_protocol == IPPROTO_TCP) {
> +			opts2 |= TCP_CS;
> +			opts2 |= (skb_transport_offset(skb) & 0x7fff) << 17;
> +		} else if (ip_protocol == IPPROTO_UDP) {
> +			opts2 |= UDP_CS;
> +		} else
> +			WARN_ON_ONCE(1);

    Stange, why *else if* branch has {} and *else* don't. It should, according 
to Documentation/CodingStyle.

> +
> +		desc->opts2 = cpu_to_le32(opts2);
> +	}
> +}
> +

WBR, Sergei
