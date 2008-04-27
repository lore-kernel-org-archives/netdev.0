From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: Slab Corruption with ipv6 and tcp6fuzz
Date: Sun, 27 Apr 2008 17:32:11 +0200
Message-ID: <20080427153211.GA6182@alice>
References: <20080425125230.GA12343@alice> <20080425130946.GA1019@2ka.mipt.ru> <20080426160519.GA5697@2ka.mipt.ru> <20080426.230549.230699327.davem@davemloft.net> <1209302742.29301.137.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	dada1@cosmosbay.com
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:59583 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754740AbYD0PcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 11:32:13 -0400
Content-Disposition: inline
In-Reply-To: <1209302742.29301.137.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McManus (mcmanus@ducksong.com) wrote:
> I'll take a look asap - thanks for the cc:, I've been away.

Evgeniys patch fixes the issue for me and i see no more corruptions.

Eric 

> > > Ok, I can not reproduce it, so lets try hard way.
> > > Can you test attached patch, its idea is described above and I checked
> > > multiple times, that it is forbidden to free skb and return non-zero
> > > value from tcp_rcv_established(). This behaviour was introduced with TCP
> > > defer accept changes in 2.6.25 with
> > > ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 commit.
> > > 
> > > Please test. This bug affects both ipv6 and ipv4 code actually.
> > > 
> > > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > > index ac9b848..0298f80 100644
> > > --- a/net/ipv4/tcp_input.c
> > > +++ b/net/ipv4/tcp_input.c
> > > @@ -4925,8 +4925,7 @@ step5:
> > >  	tcp_data_snd_check(sk);
> > >  	tcp_ack_snd_check(sk);
> > >  
> > > -	if (tcp_defer_accept_check(sk))
> > > -		return -1;
> > > +	tcp_defer_accept_check(sk);
> > >  	return 0;
> > >  
> > >  csum_error:
