From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 15:56:29 +0100
Message-ID: <20090311145629.GA34777@bts.sk>
References: <20090309200505.GA58375@bts.sk> <20090309.170927.130334650.davem@davemloft.net> <87bps8fkaw.fsf@basil.nowhere.org> <20090311.063058.236235660.davem@davemloft.net> <20090311150149.GG11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:54862 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbZCKO4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 10:56:31 -0400
Content-Disposition: inline
In-Reply-To: <20090311150149.GG11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 04:01:49PM +0100, Andi Kleen wrote:
> On Wed, Mar 11, 2009 at 06:30:58AM -0700, David Miller wrote:
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Wed, 11 Mar 2009 11:03:35 +0100
> > 
> > > Perhaps this points to the default buffer sizing heuristics to 
> > > be too aggressive for >= 1GB?
> > 
> > It's necessary Andi, you can't fill a connection on a trans-
> > continental connection without at least a 4MB receive buffer.
> 
> Seems pretty arbitary to me. It's the value for a given bandwidth*latency
> product, but why not half or twice the bandwidth? I don't think
> that number is written in stone like you claim.

Besides being arbitrary, it's also incorrect. The defaults at
tcp.c are setting both tcp_wmem and tcp_rmem to 4 MB ignoring
the fact, that it results in 4MB send buffer but only 3 MB 
receive buffer due to other defaults (tcp_adv_win_scale=2).
 
Indeed, 3MB*(1538/1448)/100Mbps is equal to 267.3 msec
- i.e. exactly the latency we're seeing.

   With kind regards,

         M.



