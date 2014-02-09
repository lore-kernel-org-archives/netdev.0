From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.53] datapath: Add basic MPLS support to kernel
Date: Mon, 10 Feb 2014 07:21:09 +0900
Message-ID: <20140209222109.GC15402@verge.net.au>
References: <1391590479-15567-1-git-send-email-horms@verge.net.au>
 <20140207161549.GB30416@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>, Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46236 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbaBIWVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 17:21:22 -0500
Content-Disposition: inline
In-Reply-To: <20140207161549.GB30416@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 07, 2014 at 08:15:49AM -0800, Ben Pfaff wrote:
> On Wed, Feb 05, 2014 at 05:54:38PM +0900, Simon Horman wrote:
> > * Ben has explained to me that there has been a change of direction
> >   at the ONF with regards to MPLS and VLAN tag ordering. As per
> >   his changelog for "Always insert MPLS labels after VLAN tags",
> >   the situation is now as follows:
> > 
> >   * OpenFlow 1.1 and 1.2 always inserted MPLS labels after VLAN tags.
> >   * OpenFlow 1.3 and 1.4 insert MPLS labels before VLAN tags.
> >   * OpenFlow 1.3.4 and 1.5, both in preparation, recognize that the change
> >     in 1.3 was an error and revert it.
> > 
> >   With this in mind only OF1.4 specifies a requirement for inserting MPLS
> >   labels before VLAN tags. This appears to be an abbertation at this
> >   point.
> > 
> >   Ben's suggestion as per his patch "Always insert MPLS labels after VLAN
> >   tags" is that Open vSwtich should only support inserting MPLS labels
> >   after VLAN tags. I agree with this. And to this end I have
> >   updated the MPLS code for the kernel datapath (this patch).
> 
> I spoke to Jesse briefly about MPLS versus VLANs a few days ago.  He
> expressed a concern about the larger problem of figuring out how all the
> various forms of tags should interact: VLAN, MPLS, PBB, and others that
> I can't think of at the moment.  It would be more consistent from this
> higher point of view if "push" and "pop" actions always acted in a
> predictable place.
> 
> I agree with that point, but it still stands that I don't know of a
> well-defined way for VLAN-inside-MPLS to function.  So here is my
> proposal for you and Jesse to consider:
> 
>         - The datapath push_mpls action is well-defined when no VLAN is
>           present.  Great.
> 
>         - Declare the behavior of the datapath push_mpls action to be
>           undefined in the presence of a VLAN for now, since we don't
>           really know what should happen.  For now, make the datapaths
>           reject any flow that does push_mpls in the presence of a VLAN.
>           Later, we can redefine that case as we please since userspace
>           should not depend on the previous behavior.
> 
>         - Modify userspace to pop_vlan, push_mpls, push_vlan if
>           necessary to avoid the undefined behavior.
> 
> Jesse, is that reasonable?

FWIW, that sounds very reasonable to me.
