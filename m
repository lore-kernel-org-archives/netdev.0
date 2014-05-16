From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 20:01:12 +0300
Message-ID: <20140516200112.114cf1bb@vostro>
References: <20140516104014.607d2d0f@vostro>
	<1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516173443.0b40157e@vostro>
	<1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516194037.4486cd63@vostro>
	<1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:50231 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbaEPRAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:00:55 -0400
Received: by mail-lb0-f181.google.com with SMTP id u14so2124147lbd.40
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:00:53 -0700 (PDT)
In-Reply-To: <1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2014 09:50:27 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2014-05-16 at 19:40 +0300, Timo Teras wrote:
> 
> > Both the gre bound interface, and the inside interface are
> > identical.
> > 
> > And you are right. It might be driver / hw / gro capability specific
> > issue. I had also report from a user using similar
> > gre/ipsec/forwarding setup, that 3.13-stable kernels works on his
> > hardware.
> > 
> 
> > Using unmodified in-tree r8169 module.
> > 
> > Please let me know if additional information is needed.
> 
> What happens if you disable gro on eth0 ?

I believe it crashes, but cannot say with 100% certainty. I can
test later on if needed. Based on earlier experiment, the only way to
avoid the crash was to turn off gro on gre1.

In any case I don't think it should make any effect, since the GRE
packets arrive IPseced. eth0 is receiving ESP packets - and I believe
there's no ESP GRO support. Only after decryption they go to gre1, so
gre1 gro is basically the place where received packets are coalesced.
