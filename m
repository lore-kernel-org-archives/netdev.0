From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.44 1/5] odp: Allow VLAN actions after MPLS actions
Date: Wed, 23 Oct 2013 07:30:44 +0100
Message-ID: <20131023063044.GF14487@verge.net.au>
References: <1381972511-27221-1-git-send-email-horms@verge.net.au>
 <1381972511-27221-2-git-send-email-horms@verge.net.au>
 <20131021204102.GD15986@nicira.com>
 <CAOftzPgSG7NO+hFEeHU0xGH5TjJRe-THGDVz7THrm26j5ua-bA@mail.gmail.com>
 <20131022205541.GA29754@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Stringer <joestringernz@gmail.com>, dev@openvswitch.org,
	netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53380 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab3JWGc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 02:32:59 -0400
Content-Disposition: inline
In-Reply-To: <20131022205541.GA29754@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 01:55:41PM -0700, Ben Pfaff wrote:
> On Tue, Oct 22, 2013 at 11:30:26AM -0700, Joe Stringer wrote:
> > You're quite right. I think for OF1.2, this is similar to existing
> > behaviour, but for OF1.3 it's just incorrect. There is an additional issue
> > with the LOAD action.
> > 
> > OF1.2:
> > "push_vlan(A),push_mpls,push_vlan(B)"
> > In OF1.2, this has the same result as:-
> > "push_mpls,push_vlan(A),push_vlan(B)"
> > 
> > When translated, this boils down to "(pop_vlan,)push_mpls,push_vlan(B)".
> > Correct me if I am wrong, but I think this is similar to the existing
> > behaviour, as we currently only support one layer of VLAN. It doesn't
> > matter if A == B.
> > 
> > OF1.3:
> > "mod_vlan_vid:A,push_mpls:0x8847,mod_vlan_vid:A" should work, but the
> > second mod_vlan is being dropped as it has the same VID as the first. This
> > is incorrect, as you point out.
> > 
> > LOAD:
> > "load:A->OXM_OF_VLAN_VID,push_mpls:0x8847,load:A->OXM_OF_VLAN_VID" doesn't
> > result in the correct vlan_vid from the first load action. I'm not sure
> > that vlan_tci_restore() is clear or correct---I believe its original
> > purpose was to properly handle the case where MPLS changes are made from
> > REG_LOAD and friends, in the way that the PUSH_MPLS case works. Instead, it
> > is handling all cases where MPLS actions have been applied in the past,
> > whether the current action modifies MPLS or not.
> > 
> > It's probably also worthwhile to make use of the ovs-ofctl monitor "-m"
> > option in the tests to actually verify these, rather than the current tests
> > where we just check the size of the resulting packet.
> 
> Thanks for the careful analysis.

Indeed, thanks Joe, I'll fix this up.

The idea that I have at this time is to track the VLAN depth delta
in a similar way to what is done for MPLS. But it is not a particularly
well thought out idea at this stage.
