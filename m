From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 08:03:40 +0000
Message-ID: <20081008080340.GE4174@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:12857 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbYJHIDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 04:03:48 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1503260nfc.21
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 01:03:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081008072203.GJ22396@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 06:22:04PM +1100, Simon Horman wrote:
> On Wed, Oct 08, 2008 at 06:55:51AM +0000, Jarek Poplawski wrote:
> > On Wed, Oct 08, 2008 at 02:31:26AM +0200, Patrick McHardy wrote:
> > ...
> > > I'm pretty sure that the differences are caused by HTB not being
> > > in control of the queue since the device is the real bottleneck
> > > in this configuration.
> > 
> > Yes, otherwise there would be no requeuing. And, btw. the golden rule
> > of scheduling/shaping is limiting below "hardware" limits.
> > 
> > > Its quite possible that there simply might
> > > a subtle timing change that causes feedback through HTBs borrowing
> > > and ceiling.
> > 
> > I'd add my previous suspicion there could be not enough enqeuing on
> > time for the fastest class (could be also very bursty), so other
> > classes can borrow more.
> > 
> > >
> > > So what would really be useful to understand this is to make HTB
> > > control the queue and see if it behaves as expected.
> > >
> > 
> > Right, trying with lower rates/ceils should explain this.
> 
> As I mentioned earlier things seem to work quite well with lower
> rates/ceilings. When I set up the classes with 10x lower values
> for rate and celing, as follows:
> 
> 
>                            [ rate=100Mbit/s ]
>                            [ ceil=100Mbit/s ]
>                                   |
>              +--------------------+--------------------+
>              |                    |                    |
>       [ rate= 50Mbit/s ]   [ rate= 10Mbit/s ]   [ rate= 10Mbit/s ]
>       [ ceil=100Mbit/s ]   [ ceil=100Mbit/s ]   [ ceil= 100Mbit/s ]
> 
> Then I get results that are fairly close to the ideal values.
> 
> net-next-2.6 - d877984
> ----------------------
> 10194: 68075482bits/s 68Mbits/s
> 10197: 14464848bits/s 14Mbits/s
> 10196: 14465632bits/s 14Mbits/s
> -----------------------------------
> total: 97005962bits/s 97Mbits/s
> 
> And I get those kind of results consistently for various
> different kernel versions.

OK. But as Patrick mentioned it would be interesting to try a little
below hardware limits: 950, or maybe lower, until HTB starts getting
accuracy.

Jarek P.
