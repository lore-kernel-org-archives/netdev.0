From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2] sctp: Fix port hash table size computation
Date: Fri, 19 Feb 2016 11:46:14 -0500
Message-ID: <20160219164614.GB20372@hmsreliant.think-freely.org>
References: <20160218.153921.2010668846576353053.davem@davemloft.net>
 <1455829857-15797-1-git-send-email-nhorman@tuxdriver.com>
 <1455877730.648.21.camel@edumazet-ThinkPad-T530>
 <20160219140703.GA20372@hmsreliant.think-freely.org>
 <1455892869.648.22.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50412 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1427257AbcBSQqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 11:46:31 -0500
Content-Disposition: inline
In-Reply-To: <1455892869.648.22.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 03:41:09PM +0100, Eric Dumazet wrote:
> On ven., 2016-02-19 at 09:07 -0500, Neil Horman wrote:
> 
> > I had actually thought about that, but to be frank I felt like the logic to
> > compute the hashsize was complex the way it was presented currently, and that my
> > rewite made it more clear, breaking it down into a few easy steps:
> > 
> > 1) compute a goal size order
> > 2) compute the target order for the largest table we want to support
> > 3) select the minimum of (1) and (2)
> > 4) allocated the largest table we can up to the size in (3)
> > 5) compute how many buckets the table we allocated in (4) supports
> > 
> > 
> > I'm happy to use your suggestion above if the consensus is that its more clear,
> > but it took me a bit to figure out what exactly the existing code was trying to
> > do (especially given the dual use of the order variable), so I thought some
> > additional clarity was called for.
> 
> No strong feelings. I only took a look in other places like
> net/dccp/proto.c for similar problem.
> 
Understood. Its clear that sctp lifted the code from dccp (or perhaps vice
versa).  Either way, looking at it, it appears dccp has the same problem that
sctp does in this area.

As you don't have strong feelings, if its all the same to Dave and Vlad, I'm
happy with the way this patch is laid out, and will move on to fix dccp in the
same manner.

Best
Neil

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
