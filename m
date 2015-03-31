From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 4/9 net-next] ipv6: replace if/BUG by BUG_ON
Date: Tue, 31 Mar 2015 12:50:27 +0900
Message-ID: <551A1983.40408@miraclelinux.com>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be> <1427749998-28464-4-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:60715 "HELO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750954AbbCaDuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 23:50:32 -0400
Received: by mail-pd0-f179.google.com with SMTP id ni2so6628251pdb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 20:50:32 -0700 (PDT)
In-Reply-To: <1427749998-28464-4-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Fabian Frederick wrote:
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/ipv6/addrconf.c                     | 3 +--
>  net/ipv6/esp6.c                         | 3 +--
>  net/ipv6/netfilter/nf_conntrack_reasm.c | 3 +--
>  3 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2660263..e205918 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4805,8 +4805,7 @@ static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
>  	if (!idev)
>  		return -EAFNOSUPPORT;
>  
> -	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
> -		BUG();
> +	BUG_ON(nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0);
>  

NACK, I do not prefer using BUG_ON() with side effects.

--yoshfuji

>  	if (tb[IFLA_INET6_TOKEN]) {
>  		err = inet6_set_iftoken(idev, nla_data(tb[IFLA_INET6_TOKEN]));
> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> index e48f2c7..9e51b69 100644
> --- a/net/ipv6/esp6.c
> +++ b/net/ipv6/esp6.c
> @@ -280,8 +280,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
>  	if (unlikely(err))
>  		goto out;
>  
> -	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
> -		BUG();
> +	BUG_ON(skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2));
>  
>  	err = -EINVAL;
>  	padlen = nexthdr[0];
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
> index 6f187c8..cea1a4a 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -538,8 +538,7 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
>  			pr_debug("too short\n");
>  			return -1;
>  		}
> -		if (skb_copy_bits(skb, start, &hdr, sizeof(hdr)))
> -			BUG();
> +		BUG_ON(skb_copy_bits(skb, start, &hdr, sizeof(hdr)));
>  		if (nexthdr == NEXTHDR_AUTH)
>  			hdrlen = (hdr.hdrlen+2)<<2;
>  		else
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
