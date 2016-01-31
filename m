From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sun, 31 Jan 2016 16:23:52 -0500
Message-ID: <20160131212352.GA31924@oracle.com>
References: <CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
 <20160130.194507.777391919166997236.davem@davemloft.net>
 <CAKgT0UepN041H4QcWkoNWnzGgf=yo71w8_3-JQKFFNBegQVpzA@mail.gmail.com>
 <20160131.111736.885803938247704593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.duyck@gmail.com, eric.dumazet@gmail.com,
	aduyck@mirantis.com, netdev@vger.kernel.org, tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19816 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757294AbcAaVYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 16:24:11 -0500
Content-Disposition: inline
In-Reply-To: <20160131.111736.885803938247704593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/31/16 11:17), David Miller wrote:
> 
> > If nothing else we can discuss this further in Seville as I am just
> > not convinced changing the drivers is the right way to go about fixing
> > this, and I won't have the time to really get around to doing any of
> > it until I have come back from the conference.
> 
> Ok, let me think about this some more.
> 
> It's a shame that "put two garbage bytes into the FIFO at the
> beginning of every frame" isn't a standard hw feature.  Or maybe
> I misunderstand what's going on in all of these drivers...
> 

We can follow up on this at Seville, but if it is possible,
it might be better to not overload eth_get_headlen to also
do the flow extraction even before the buffer has been aligned
by the driver. Even the NET_IP_ALIGN algorithm will fail if we 
are dealing with IEEE 802.3 headers with LLC/SNAP etc.

And in addition to all this, anything we can do to help align
nested encapsulations  (i.e., Tom's concern) is also needed, and
maybe it will be cleaner to do that if we just split off deep packet
inspection for flow extraction away from eth_get_headlen.

--Sowmini
