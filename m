From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] tcp: fix wrong checksum calculation on MTU probing
Date: Thu, 22 Sep 2016 14:12:42 +0300
Message-ID: <5ffc1020-a36f-75b4-ff25-4f58c243f803@cogentembedded.com>
References: <15e3bab9-f21e-9a55-a87e-e389f633f755@taghos.com.br>
 <20160920.225729.1715125475365382873.davem@davemloft.net>
 <2923a9bc-c433-7546-cd4a-9f834bd43181@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org
To: Douglas Caetano dos Santos <douglascs@taghos.com.br>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33151 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756703AbcIVLMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 07:12:46 -0400
Received: by mail-lf0-f49.google.com with SMTP id b71so37697859lfg.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 04:12:45 -0700 (PDT)
In-Reply-To: <2923a9bc-c433-7546-cd4a-9f834bd43181@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/21/2016 9:26 PM, Douglas Caetano dos Santos wrote:

> With TCP MTU probing enabled and offload TX checksumming disabled,
> tcp_mtu_probe() calculated the wrong checksum when a fragment being copied
> into the probe's SKB had an odd length. This was caused by the direct use
> of skb_copy_and_csum_bits() to calculate the checksum, as it pads the
> fragment being copied, if needed. When this fragment was not the last, a
> subsequent call used the previous checksum without considering this
> padding.
>
> The effect was a stale connection in one way, as even retransmissions
> wouldn't solve the problem, because the checksum was never recalculated for
> the full SKB length.
>
> Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>
> ---
>  net/ipv4/tcp_output.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index f53d0cc..767135e 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1968,10 +1968,12 @@ static int tcp_mtu_probe(struct sock *sk)
>  		copy = min_t(int, skb->len, probe_size - len);
>  		if (nskb->ip_summed)
>  			skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
> -		else
> -			nskb->csum = skb_copy_and_csum_bits(skb, 0,
> -							    skb_put(nskb, copy),
> -							    copy, nskb->csum);
> +		else {

    CodingStyle: now the first branch needs {} too.

[...]

MBR, Sergei
