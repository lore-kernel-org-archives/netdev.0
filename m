From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 16:45:12 -0700 (PDT)
Message-ID: <20060414.164512.17280154.davem@davemloft.net>
References: <Pine.WNT.4.63.0604141533250.2116@jbrandeb-desk.amr.corp.intel.com>
	<20060414.155129.121789313.davem@davemloft.net>
	<Pine.WNT.4.63.0604141555200.2116@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	Jeffrey.t.kirsher@intel.com, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11906
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751258AbWDNXqC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 19:46:02 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0604141555200.2116@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 16:04:21 -0700 (Pacific Daylight Time)

> On Fri, 14 Apr 2006, David S. Miller wrote:
> 
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Date: Fri, 14 Apr 2006 15:43:02 -0700 (Pacific Daylight Time)
> > 
> > > Please help me understand how you think it should work when we have a 
> > > device that wants to receive a packet using header in the skb->data, and 
> > > application data in the ->frags[]? 
> > 
> > If you're removing the pages from ->frags[] and you already accounted
> > for them in skb->truesize, then yes I guess it could be correct to
> > subtract it back out.
> 
> they are not accounted for in the skb yet.  the way e1000 works is it 
> pre-allocates all its 128 byte receive buffers using skb_alloc, and then 
> chains in any pages that are used for receive packets.

Ok so you allocate the base skb->data memory using alloc_skb().  Then
you add on pages and increment skb->truesize to account for the pages.
And you do all of this for receive packets before they are passed up
to the stack.

Right?

If so, then that should be OK.

Jeff, I seem to have misunderstood what e1000 was doing, the patches
changing skb->truesize should be fine.
