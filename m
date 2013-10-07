From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.42 2/5] ofp-actions: Add separate OpenFlow 1.3 action
 parser
Date: Mon, 7 Oct 2013 15:25:47 +0900
Message-ID: <20131007062544.GE19926@verge.net.au>
References: <1380874200-8981-1-git-send-email-horms@verge.net.au>
 <1380874200-8981-3-git-send-email-horms@verge.net.au>
 <20131004163105.GH29572@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37682 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab3JGGZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 02:25:56 -0400
Content-Disposition: inline
In-Reply-To: <20131004163105.GH29572@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 09:31:05AM -0700, Ben Pfaff wrote:
> On Fri, Oct 04, 2013 at 05:09:57PM +0900, Simon Horman wrote:
> > From: Joe Stringer <joe@wand.net.nz>
> > 
> > This patch adds new ofpact_from_openflow13() and
> > ofpacts_from_openflow13() functions parallel to the existing ofpact
> > handling code. In the OpenFlow 1.3 version, push_mpls is handled
> > differently, but all other actions are handled by the existing code.
> > 
> > In the case of push_mpls for OpenFlow 1.3 the new mpls_before_vlan field of
> > struct ofpact_push_mpls is set to true.  This will be used by a subsequent
> > patch to allow allow the correct VLAN+MPLS datapath behaviour to be
> > determined at odp translation time.
> > 
> > Signed-off-by: Joe Stringer <joe@wand.net.nz>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> The need for a huge comment on mpls_before_vlan suggests to me that
> breaking it out as a separate type would be helpful.  How about this:
> 
> /* The position in the packet at which to insert an MPLS header.
>  *
>  * Used NXAST_PUSH_MPLS, OFPAT11_PUSH_MPLS. */
> enum ofpact_mpls_position {
>     /* Add the MPLS LSE after the Ethernet header but before any VLAN tags.
>      * OpenFlow 1.3+ requires this behavior. */
>     OFPACT_MPLS_BEFORE_VLAN,
> 
>     /* Add the MPLS LSE after the Ethernet header and any VLAN tags.
>      * OpenFlow 1.1 and 1.2 require this behavior. */
>     OFPACT_MPLS_AFTER_VLAN
> };
> 
> /* OFPACT_PUSH_VLAN/MPLS/PBB
>  *
>  * Used for NXAST_PUSH_MPLS, OFPAT11_PUSH_MPLS. */
> struct ofpact_push_mpls {
>     struct ofpact ofpact;
>     ovs_be16 ethertype;
>     enum ofpact_mpls_position position;
> };

Hi Ben,

thanks, that looks very nice.
I will incorporate it in the next revision of the patchset.
