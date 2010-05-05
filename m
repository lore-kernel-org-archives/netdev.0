From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 3 packet TCP window limit?
Date: Wed, 05 May 2010 13:23:12 -0700
Message-ID: <4BE1D3B0.9000207@hp.com>
References: <alpine.LNX.2.00.1005050210230.8544@d>	<4BE171EC.20904@athenacr.com> <alpine.LNX.2.00.1005051239290.28957@d>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Bloniarz <bmb@athenacr.com>, netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:5241 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344Ab0EEUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 16:23:15 -0400
In-Reply-To: <alpine.LNX.2.00.1005051239290.28957@d>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dormando wrote:
>>This sounds like TCP slow start.
>>
>>http://en.wikipedia.org/wiki/Slow-start
>>
>>As far as tunables you might want to play with the initcwnd route
>>flag (see "ip route help")
> 
> Ah, yes, initcwnd was it. I'm well aware of TCP Congestion control / slow
> start / etc. However I couldn't find the damn tunable for it :)

I don't believe linux as yet has a damn tunable for it :)

> ssthresh/tso/etc didn't seem to unwedge it. 

If they did, it would be a bug.  In fact there *was* a bug "way back when" where 
TSO being enabled caused the stack to ignore initcwd, but that was fixed circa 
2.6.14.  Until it was fixed (it was difficult to notice unless one was speaking 
to a non-Linux reciever, since Linux receivers autotune the receive window) it 
did some very nice things for SPECweb benchmark results :)

> Felt like describing it in the most generic way possible would help :)
> 
> Other OS's appear to have a larger initcwnd.

Names?  Values?

> As do commercial load balancers.

Names?  Values?

> The default of 3 seems to be tuned for 56k dialup modems. I'm a
> little surprised that none of the pluggable TCP congestion control
> algorithms changed this value. I went through all of them except for
> tcp_yeah.

The initcwnd comes from IETF RFCs and their "thou shalts" and "thou shalt nots." 
  As you note below, Google et al seek to alter/extend the RFCs.  That is an 
ongoing discussion in some of the ietf related mailing lists.

rick jones

> Anyway, thanks and sorry for the nearly off-topic post here. I see some
> google papers on bumping initcwnd to 10... but I guess that's not linux's
> deal yet.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

