From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 22:10:27 +0200
Message-ID: <20090519201027.GA4751@ami.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090516141430.GB3013@ami.dom.local> <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com> <1242688479.9558.60.camel@hazard2.francoudi.com> <1242689267.11814.1.camel@hazard2.francoudi.com> <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Antonio Almeida <vexwek@gmail.com>
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:41854 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbZESUMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 16:12:43 -0400
Received: by bwz22 with SMTP id 22so24208bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 13:12:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090519140416.GA21270@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 05:04:16PM +0300, Vladimir Ivashchenko wrote:
> > > Please disregard my comment about HFSC. It still overspills heavily.
> > > 
> > > On a 400 mbps limit, I'm getting 520 mbps actual throughput.
> > 
> > I guess you should send some logs. Your previous report seem to show
> 
> Can you give some hints on which logs you would like to see?

Similarly to Antonio's: ifconfigs and tc -s for qdiscs and classes at
the beginning and at the end of testing.

> > the sum of sc rates of of children could be too high. You seem to
> > expect the parent's sc and ul should limit this, but actually children
> > rates decide and parent's rates are mainly for lending/borrowing (at
> 
> The children's ceil rate is 70% of the parent 1:2 class rate.

How about children's main rates?

> > least in HTB). So, it would be nice to try with one leaf class first,
> > (similarly to Antonio) how high rates are respected.
> 
> Unfortunately its difficult for me to play with classes as its real traffic. 
> I'll try to get a traffic generator.

Let it be the real traffic, but please re-check these rates sums.

> > High drop should be OK if the flow is much faster than scheduling/
> > hardware send rate. It could be a bit higher than in older kernels
> > because of limited requeuing, but this could be corrected with
> > longer queue lenghts (sfq has a very short queue: max 127).
> 
> I don't think its sfq, since I have the same sfq qdiscs with HSFC.
> 
> Also I'm comparing this to my production HTB box has 2.6.21.5 with esfq 
> and no bond (just eth), esfq also has 127p limit.
> 
> I tried to get rid of bond on the outbound traffic, I balanced traffic
> via eth0 and eth2 manually by splitting routes going through them.
> 
> I still had the same issue with HTB not reaching the full speed.
> 
> I'm going to try testing exactly the same configuration on 2.6.29 as I have
> on 2.6.21.5 tonight. The only difference would be that I use sfq(dst) instead of
> esfq(dst) which is not available on 2.6.29.

I'm a bit lost about your configs/results and not reaching vs.
overspilled, so please send some new data to compare (gzipped?).

Jarek P. 
