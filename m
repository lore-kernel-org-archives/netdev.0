From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Wed, 22 Aug 2012 00:07:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208212355060.2149@ja.ssi.bg>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>  <1345555336.5158.493.camel@edumazet-glaptop>  <1345560131.5158.500.camel@edumazet-glaptop>  <alpine.LFD.2.00.1208211815550.2149@ja.ssi.bg>  <1345567633.5158.534.camel@edumazet-glaptop>
  <alpine.LFD.2.00.1208211954380.2149@ja.ssi.bg>  <1345569824.5158.540.camel@edumazet-glaptop>  <alpine.LFD.2.00.1208212102540.2149@ja.ssi.bg> <1345582019.5158.547.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58811 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758409Ab2HUVFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 17:05:25 -0400
In-Reply-To: <1345582019.5158.547.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 21 Aug 2012, Eric Dumazet wrote:

> > 	dst_update_expires will be like dst_set_expires
> > but with this difference (time_after):
> > 
> > 	if (dst->expires == 0 || time_after(expires, dst->expires) ||
> > 	    !timeout)
> 
> Hmm, all these tests are not really needed, what about :
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e4ba974..8d6d320 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -956,7 +956,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
>  		dst->obsolete = DST_OBSOLETE_KILL;
>  	} else {
>  		rt->rt_pmtu = mtu;
> -		dst_set_expires(&rt->dst, ip_rt_mtu_expires);
> +		rt->dst.expires = max(1UL, jiffies + ip_rt_mtu_expires);

	The best solution, I think.

>  	}
>  }

Regards

--
Julian Anastasov <ja@ssi.bg>
