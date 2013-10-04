From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.42 2/5] ofp-actions: Add separate OpenFlow 1.3 action
 parser
Date: Fri, 4 Oct 2013 09:31:05 -0700
Message-ID: <20131004163105.GH29572@nicira.com>
References: <1380874200-8981-1-git-send-email-horms@verge.net.au>
 <1380874200-8981-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:54608 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754800Ab3JDQbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 12:31:12 -0400
Received: by mail-pa0-f47.google.com with SMTP id kp14so4367269pab.6
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 09:31:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380874200-8981-3-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 05:09:57PM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> This patch adds new ofpact_from_openflow13() and
> ofpacts_from_openflow13() functions parallel to the existing ofpact
> handling code. In the OpenFlow 1.3 version, push_mpls is handled
> differently, but all other actions are handled by the existing code.
> 
> In the case of push_mpls for OpenFlow 1.3 the new mpls_before_vlan field of
> struct ofpact_push_mpls is set to true.  This will be used by a subsequent
> patch to allow allow the correct VLAN+MPLS datapath behaviour to be
> determined at odp translation time.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

The need for a huge comment on mpls_before_vlan suggests to me that
breaking it out as a separate type would be helpful.  How about this:

/* The position in the packet at which to insert an MPLS header.
 *
 * Used NXAST_PUSH_MPLS, OFPAT11_PUSH_MPLS. */
enum ofpact_mpls_position {
    /* Add the MPLS LSE after the Ethernet header but before any VLAN tags.
     * OpenFlow 1.3+ requires this behavior. */
    OFPACT_MPLS_BEFORE_VLAN,

    /* Add the MPLS LSE after the Ethernet header and any VLAN tags.
     * OpenFlow 1.1 and 1.2 require this behavior. */
    OFPACT_MPLS_AFTER_VLAN
};

/* OFPACT_PUSH_VLAN/MPLS/PBB
 *
 * Used for NXAST_PUSH_MPLS, OFPAT11_PUSH_MPLS. */
struct ofpact_push_mpls {
    struct ofpact ofpact;
    ovs_be16 ethertype;
    enum ofpact_mpls_position position;
};

Thanks,

Ben.
