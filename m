From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Sat, 16 Oct 2004 19:45:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041016094553.GA6546@gondor.apana.org.au>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org> <E1CI2I2-0001sI-00@gondolin.me.apana.org.au> <20041014105757.GB12694@obroa-skai.de.gnumonks.org> <20041014110742.GA7910@gondor.apana.org.au> <20041015191444.GM17516@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20041015191444.GM17516@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 15, 2004 at 09:14:44PM +0200, Harald Welte wrote:
> 
> Pleae find a proposed patch attached to this email.  I didn't have the
> means to test it at this point, though.. but it's pretty
> straightforward.  Please consider applying it...

Thanks for the patch.
 
> --- linux-2.6.9-rc3-bk9-test/net/ipv4/tcp_diag.c	2004-10-10 14:01:47.000000000 +0200
> +++ linux-2.6.9-rc3-bk9-test-xfrm_netlink/net/ipv4/tcp_diag.c	2004-10-15 21:02:19.000000000 +0200
> @@ -97,7 +97,7 @@
>  }
>  
>  static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
> -			int ext, u32 pid, u32 seq)
> +			int ext, u32 pid, u32 seq, u16 nlmsg_flags)

The patch looks OK.  But I have some pending patches in this area (see
http://oss.sgi.com/projects/netdev/archive/2004-10/msg00456.html).
Could you please hold off on it for a while?
  				}
> diff -Nru linux-2.6.9-rc3-bk9-test/net/xfrm/xfrm_user.c linux-2.6.9-rc3-bk9-test-xfrm_netlink/net/xfrm/xfrm_user.c
> --- linux-2.6.9-rc3-bk9-test/net/xfrm/xfrm_user.c	2004-10-10 14:01:03.000000000 +0200
> +++ linux-2.6.9-rc3-bk9-test-xfrm_netlink/net/xfrm/xfrm_user.c	2004-10-15 20:55:58.000000000 +0200
> @@ -351,7 +351,10 @@
>  	nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
>  			sp->nlmsg_seq,
>  			XFRM_MSG_NEWSA, sizeof(*p));
> -	nlh->nlmsg_flags = 0;
> +	if (count != 0)
> +		nlh->nlmsg_flags = NLM_F_MULTI;
> +	else
> +		nlh->nlmsg_flags = 0;
>  
>  	p = NLMSG_DATA(nlh);
>  	copy_to_user_state(x, p);

I think count can be zero when you're dumping as well.  You probably
want to change dump_one_policy while you're at it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
