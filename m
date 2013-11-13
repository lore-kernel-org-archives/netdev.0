From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Wed, 13 Nov 2013 07:06:25 -0800
Message-ID: <1384355185.28458.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
	 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113012920.GA27897@gondor.apana.org.au>
	 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113022243.GA28204@gondor.apana.org.au>
	 <20131113022525.GA28236@gondor.apana.org.au>
	 <1384310704.28458.79.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113142615.GA1851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:54882 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055Ab3KMPG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 10:06:28 -0500
Received: by mail-pd0-f173.google.com with SMTP id x10so524237pdj.32
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 07:06:27 -0800 (PST)
In-Reply-To: <20131113142615.GA1851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 22:26 +0800, Herbert Xu wrote:
> On Tue, Nov 12, 2013 at 06:45:04PM -0800, Eric Dumazet wrote:
> > On Wed, 2013-11-13 at 10:25 +0800, Herbert Xu wrote:
> > 
> > > So a better test for the time being would be to test with TSO
> > > disabled in both cases.
> > > 
> > 
> > GRO on, TSO off, little difference between two cases :
> > 
> > (Note some small things run in background, so these numbers are not
> > ultra precise)
> 
> OK looks pretty sane.
>  
> > > In the mean time I'm cooking up a patch to generate TSO packets.
> > 
> > That would be very nice !
> 
> It's failing on my machine but I'm not certain whether it's a bug
> in my patch or a bug in my NIC's TSO code.  So I'd appreciate it
> if you can give this a spin on your mlx4.
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 557e1a5..1302515 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c


Well, I wont try this patch, as it can not possibly work :(

The problem is not only skb_segment() but all its callers / users, as I
mentioned yesterday.

Specifically, you'll have to change inet_gso_segment(),
gre_gso_segment(), tcp_gso_segment(), ipv6_gso_segment(),
udp6_ufo_fragment() ...

Yes, we have to propagate correct IP id identifiers, and correct tcp
sequence numbers, tcp checksums.
