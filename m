From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH] staging/octeon: Software should check the checksum of
 no tcp/udp packets
Date: Mon, 26 Sep 2011 12:50:44 -0700
Message-ID: <4E80D794.3040701@cavium.com>
References: <1316999280-11999-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Greg KH <greg@kroah.com>
To: rongqing.li@windriver.com, netdev@vger.kernel.org,
	ralf@linux-mips.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:16821 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab1IZTup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 15:50:45 -0400
In-Reply-To: <1316999280-11999-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2011 06:08 PM, rongqing.li@windriver.com wrote:
> From: Roy.Li<rongqing.li@windriver.com>
>
> Icmp packets with wrong checksum are never dropped since
> skb->ip_summed is set to CHECKSUM_UNNECESSARY.
>
> When icmp packets with wrong checksum pass through the octeon
> net driver, the not_IP, IP_exc, L4_error hardware indicators
> show no error. so the driver sets CHECKSUM_UNNECESSARY on
> skb->ip_summed.
>
> L4_error only works for TCP/UDP, not for ICMP.
>
> Signed-off-by: Roy.Li<rongqing.li@windriver.com>

We found the same problem, but have not yet sent the patch to fix it.

This looks fine to me,

Acked-by: David Daney <david.daney@cavium.com>

I would let davem, Ralf and Greg KH fight over who gets to merge it.

David Daney

> ---
>   drivers/staging/octeon/ethernet-rx.c |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
> index 1a7c19a..1747024 100644
> --- a/drivers/staging/octeon/ethernet-rx.c
> +++ b/drivers/staging/octeon/ethernet-rx.c
> @@ -411,7 +411,8 @@ static int cvm_oct_napi_poll(struct napi_struct *napi, int budget)
>   				skb->protocol = eth_type_trans(skb, dev);
>   				skb->dev = dev;
>
> -				if (unlikely(work->word2.s.not_IP || work->word2.s.IP_exc || work->word2.s.L4_error))
> +				if (unlikely(work->word2.s.not_IP || work->word2.s.IP_exc ||
> +					work->word2.s.L4_error || !work->word2.s.tcp_or_udp))
>   					skb->ip_summed = CHECKSUM_NONE;
>   				else
>   					skb->ip_summed = CHECKSUM_UNNECESSARY;
