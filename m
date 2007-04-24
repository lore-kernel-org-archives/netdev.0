From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Wed, 25 Apr 2007 00:58:45 +0900 (JST)
Message-ID: <20070425.005845.113682267.yoshfuji@linux-ipv6.org>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
	<20070424155324.GL3468@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@osdl.org, netdev@vger.kernel.org,
	tglx@linutronix.de, yoshfuji@linux-ipv6.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32869 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636AbXDXP6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 11:58:48 -0400
In-Reply-To: <20070424155324.GL3468@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070424155324.GL3468@stusta.de> (at Tue, 24 Apr 2007 17:53:24 +0200), Adrian Bunk <bunk@stusta.de> says:

> On Wed, Apr 25, 2007 at 12:17:43AM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > Recent ktime_t changes had introduced linkage errors.
> > 
> > | WARNING: "__divdi3" [net/ipv4/tcp_veno.ko] undefined!
> > | WARNING: "__divdi3" [net/ipv4/tcp_vegas.ko] undefined!
> > | WARNING: "__divdi3" [net/ipv4/tcp_lp.ko] undefined!
> > | WARNING: "__divdi3" [net/ipv4/tcp_illinois.ko] undefined!
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > 
> > ---
> > diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
> > index 8e31659..0cec615 100644
> > --- a/net/ipv4/tcp_illinois.c
> > +++ b/net/ipv4/tcp_illinois.c
> > @@ -87,10 +87,12 @@ static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
> >  {
> >  	struct illinois *ca = inet_csk_ca(sk);
> >  	u32 rtt;
> > +	struct timeval tv;
> >  
> >  	ca->acked = pkts_acked;
> >  
> > -	rtt = ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
> > +	tv = ktime_to_timeval(net_timedelta(last));
> > +	rtt = tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
> >  
> >  	/* ignore bogus values, this prevents wraparound in alpha math */
> >  	if (rtt > RTT_MAX)
> >...
> 
> Couldn't this be better solved by adding something like the following 
> to include/linux/ktime.h ?
> 
> static inline s64 ktime_to_us(const ktime_t kt)
> {
>    return (s64) kt.tv.sec * USEC_PER_SEC + kt.tv.nsec / NSEC_PER_USEC;
> }
> 

That will introduce same error, won't it?

--yoshfuji
