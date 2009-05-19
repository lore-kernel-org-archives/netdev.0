From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 11:03:11 +0000
Message-ID: <20090519110311.GA5521@ff.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090516141430.GB3013@ami.dom.local> <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com> <1242688479.9558.60.camel@hazard2.francoudi.com> <1242689267.11814.1.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Antonio Almeida <vexwek@gmail.com>
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:11966 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZESLDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 07:03:19 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1225504wah.21
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 04:03:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1242689267.11814.1.camel@hazard2.francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 02:27:47AM +0300, Vladimir Ivashchenko wrote:
> 
> > With bond + HFSC + sfq, I'm able to reach the speed. It doesn't seem to
> > overspill with 580 mbps load. Jarek, would your patches help with HSFC
> > overspill ? I will check tomorrow under 750 mbps load. 

The gen_estimator patch should fix only the effect of rising rate
after flow stop, and maybe similar overflows while reporting rates
around 1Gbit. It would show on tc stats of HFSC or HTB, but doesn't
affect actual scheduling rates.

The iproute2 tc_core patch can matter for HTB scheduling rates if
there are a lot of small packets (e.g. 100 byte for rate 500Mbit)
possibly mixed with bigger ones. It doesn't matter for HFSC or
rates <100Mbit.

> Please disregard my comment about HFSC. It still overspills heavily.
> 
> On a 400 mbps limit, I'm getting 520 mbps actual throughput.

I guess you should send some logs. Your previous report seem to show
the sum of sc rates of of children could be too high. You seem to
expect the parent's sc and ul should limit this, but actually children
rates decide and parent's rates are mainly for lending/borrowing (at
least in HTB). So, it would be nice to try with one leaf class first,
(similarly to Antonio) how high rates are respected.

High drop should be OK if the flow is much faster than scheduling/
hardware send rate. It could be a bit higher than in older kernels
because of limited requeuing, but this could be corrected with
longer queue lenghts (sfq has a very short queue: max 127).

Jarek P.
