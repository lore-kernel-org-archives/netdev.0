From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5 1/3] net: ipv6: Unduplicate {raw,udp}v6_sendmsg code
Date: Fri, 25 Apr 2014 23:26:42 +0200
Message-ID: <20140425212642.GD7050@order.stressinduktion.org>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6FF01A@AcuExch.aculab.com> <20140425.125155.861435686727308330.davem@davemloft.net> <20140425171909.GB7050@order.stressinduktion.org> <20140425.133303.375967970436600096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David.Laight@ACULAB.COM, lorenzo@google.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40545 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbaDYV0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 17:26:44 -0400
Content-Disposition: inline
In-Reply-To: <20140425.133303.375967970436600096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 01:33:03PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 25 Apr 2014 19:19:09 +0200
> 
> > Maybe we can put all those hlimit, tclass, dontfrag vars into a struct
> > and just pass one pointer.
> 
> It's still an unnecessary memory dereference.

True, true.

> The compiler can potentially optimize the accesses to those variables
> into a local register with the existing code, with this consolidation
> it no longer can.

We could hack up the function in a local header file in net/ipv6 and
__always_inline it. If the resulting assembly looks good would this
be acceptable for you? Maybe we could switch to something like struct
ipv6_output_opts where we gather all those state variables common to
the code paths.

Thanks,

  Hannes
