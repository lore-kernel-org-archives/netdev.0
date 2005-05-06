From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Fri, 06 May 2005 23:22:42 +1000
Message-ID: <E1DU2mw-0000UK-00@gondolin.me.apana.org.au>
References: <427AA319.1040906@trash.net>
Cc: davem@davemloft.net, dlstevens@us.ibm.com, laforge@gnumonks.org,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        pb@bieringer.de, usagi-users@linux-ipv6.org,
        yasuyuki.kozakai@toshiba.co.jp, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <427AA319.1040906@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> +static inline int mld_dev_queue_xmit2(struct sk_buff *skb)
> +{
> +       struct net_device *dev = skb->dev;
> +
> +       if (dev->hard_header) {
> +               unsigned char ha[MAX_ADDR_LEN];
> +               int err;
> +
> +               ndisc_mc_map(&skb->nh.ipv6h->daddr, ha, dev, 1);
> +               err = dev->hard_header(skb, dev, ETH_P_IPV6, ha, NULL, skb->len);
> +               if (err < 0) {
> +                       IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);

You're now incrementing this twice since the callers will also
increment this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
