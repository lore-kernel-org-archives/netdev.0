From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Fri, 3 Feb 2017 13:06:07 +0100
Message-ID: <20170203120607.GA289@x4>
References: <20170202115240.GH17590@x4>
 <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170202123427.GA7212@x4>
 <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203115457.GA5296@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:51632 "EHLO
        mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdBCMGQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 07:06:16 -0500
Content-Disposition: inline
In-Reply-To: <20170203115457.GA5296@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017.02.03 at 09:54 -0200, Marcelo Ricardo Leitner wrote:
> On Thu, Feb 02, 2017 at 05:59:24AM -0800, Eric Dumazet wrote:
> > On Thu, 2017-02-02 at 05:31 -0800, Eric Dumazet wrote:
> > 
> > > Anyway, I suspect the test is simply buggy ;)
> > > 
> > > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > > index 41dcbd568cbe2403f2a9e659669afe462a42e228..5394a39fcce964a7fe7075b1531a8a1e05550a54 100644
> > > --- a/net/ipv4/tcp_input.c
> > > +++ b/net/ipv4/tcp_input.c
> > > @@ -164,7 +164,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
> > >  	if (len >= icsk->icsk_ack.rcv_mss) {
> > >  		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> > >  					       tcp_sk(sk)->advmss);
> > > -		if (unlikely(icsk->icsk_ack.rcv_mss != len))
> > > +		if (unlikely(icsk->icsk_ack.rcv_mss != len && skb_is_gso(skb)))
> > >  			tcp_gro_dev_warn(sk, skb);
> > >  	} else {
> > >  		/* Otherwise, we make more careful check taking into account,
> > 
> > This wont really help.
> > 
> > Our tcp_sk(sk)->advmss can be lower than the MSS used by the remote
> > peer.
> > 
> > ip ro add .... advmss 512
> 
> I don't follow. With a good driver, how can advmss be smaller than the
> MSS used by the remote peer? Even with the route entry above, I get
> segments just up to advmss, and no warning.
> 
> Though yeah, interesting that this driver doesn't even support GRO. FCS
> perhaps?
> 
> Markus, do you have other interfaces in your system? Which MTU do you
> use, and please try the (untested) patch below, to gather more debug
> info:

No, eth0 is the only interface. MTU = 1500.
Sure, I will try your patch. But I don't know how to reproduce the
issue, so you will have to wait until it triggers again.

-- 
Markus
