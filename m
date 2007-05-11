From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 11:37:14 +0200
Message-ID: <20070511093714.GR2012@bingen.suse.de>
References: <p73wszfenni.fsf@bingen.suse.de> <OFAF0AE4C2.388D2428-ON652572D8.002E0FFF-652572D8.002EF597@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, ak@suse.de,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:48366 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbXEKIkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 04:40:04 -0400
Content-Disposition: inline
In-Reply-To: <OFAF0AE4C2.388D2428-ON652572D8.002E0FFF-652572D8.002EF597@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 02:02:55PM +0530, Krishna Kumar2 wrote:
> Hi Andy,
> 
> ak@suse.de wrote on 05/11/2007 02:35:05 PM:
> 
> > You don't need that. You can just use the normal next/prev pointers.
> > In general it's a good idea to lower lock overhead etc., the VM has
> > used similar tricks very successfully in the past.
> 
> Does this mean each skb should be for the same connection if next/prev
> is used ?

No; but see next paragraph.

But without it aggregation  on RX is much less useful because the packets
cannot be kept together after socket demux which happens relatively early
in the packet processing path.

> 
> > Another problem is that this setup typically requires the aggregate
> > packets to be from the same connection. Otherwise you will only
> > safe a short trip into the stack until the linked packet would need
> > to be split again to pass to multiple sockets. With that the scheme
> > probably helps much less.
> 
> I guess you meant this for receives only. On the send side, packets

Yes.

> for different sockets can be linked and sent together, right ?

Not implemented and as DaveM pointed out such batching
has some problems.  There is just TSO/GSO for single sockets

> 
> > Or you could do this only if multiple packets belong to the same
> > single connection (basically with a one hit cache); but then it would
> 
> But for sends, why does same or different connection matter ? There is
> no aggregating of skbs.

I wasn't talking about sending.


But there actually is :- TSO/GSO.


-Andi

> 
> Thanks,
> 
> - KK
> 
