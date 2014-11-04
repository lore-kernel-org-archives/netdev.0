From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1 net-next] esp4: remove assignment in if condition
Date: Tue, 04 Nov 2014 20:42:49 +0100
Message-ID: <54592C39.9070904@redhat.com>
References: <1415129311-12480-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732AbaKDTnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 14:43:45 -0500
In-Reply-To: <1415129311-12480-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2014 08:28 PM, Fabian Frederick wrote:
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>   net/ipv4/esp4.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
> index 360b565..9dd66ee 100644
> --- a/net/ipv4/esp4.c
> +++ b/net/ipv4/esp4.c
> @@ -392,8 +392,11 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
>   	if (elen <= 0)
>   		goto out;
>
> -	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
> +	err = skb_cow_data(skb, 0, &trailer);
> +

If you already feel the need to change this (?), then please don't
add an extra newline here ...

> +	if (err < 0)
>   		goto out;
> +
>   	nfrags = err;
>
>   	assoclen = sizeof(*esph);
>
