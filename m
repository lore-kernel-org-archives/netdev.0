From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 net-next] esp4: remove assignment in if condition
Date: Tue, 04 Nov 2014 11:33:51 -0800
Message-ID: <1415129631.23168.3.camel@perches.com>
References: <1415129311-12480-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415129311-12480-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-11-04 at 20:28 +0100, Fabian Frederick wrote:

trivia:

> diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
[]
> @@ -392,8 +392,11 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
>  	if (elen <= 0)
>  		goto out;
>  
> -	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
> +	err = skb_cow_data(skb, 0, &trailer);
> +
> +	if (err < 0)
>  		goto out;

Generally it's better/more common to use

	foo = bar();
	if (!foo)
		[error_handler...]
	
without the blank line between the set
and the test.
