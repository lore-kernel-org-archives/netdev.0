From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next 1/5] {IPv4,xfrm} Add ESN support for AH egress
 part
Date: Mon, 13 Jan 2014 22:37:16 +0400
Message-ID: <52D4325C.9050508@cogentembedded.com>
References: <1389599324-5174-1-git-send-email-fan.du@windriver.com> <1389599324-5174-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:50296 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbaAMShS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 13:37:18 -0500
Received: by mail-lb0-f180.google.com with SMTP id n15so1412856lbi.11
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 10:37:16 -0800 (PST)
In-Reply-To: <1389599324-5174-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 13-01-2014 11:48, Fan Du wrote:

> This patch add esn support for AH output stage by attaching upper 32bits
> sequence number right after packet payload as specified by RFC 4302.

> Then the ICV value will guard upper 32bits sequence number as well when
> packet going out.

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   net/ipv4/ah4.c |   25 +++++++++++++++++++++----
>   1 file changed, 21 insertions(+), 4 deletions(-)

> diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
> index 7179026..a7fac03 100644
> --- a/net/ipv4/ah4.c
> +++ b/net/ipv4/ah4.c
[...]
> @@ -213,7 +223,14 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
>   	sg_init_table(sg, nfrags);
>   	skb_to_sgvec(skb, sg, 0, skb->len);
>
> -	ahash_request_set_crypt(req, sg, icv, skb->len);
> +	if ((x->props.flags & XFRM_STATE_ESN)) {

    What's the point in double parens here? The same question about the other 
patches....

WBR, Sergei
