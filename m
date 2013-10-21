From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.44 1/5] odp: Allow VLAN actions after MPLS actions
Date: Mon, 21 Oct 2013 13:41:02 -0700
Message-ID: <20131021204102.GD15986@nicira.com>
References: <1381972511-27221-1-git-send-email-horms@verge.net.au>
 <1381972511-27221-2-git-send-email-horms@verge.net.au>
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
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:50927 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751110Ab3JUUlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 16:41:15 -0400
Received: by mail-qe0-f47.google.com with SMTP id b4so4155675qen.20
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 13:41:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1381972511-27221-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 10:15:07AM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> OpenFlow 1.1 and 1.2, and 1.3 differ in their handling of MPLS actions in the
> presence of VLAN tags. To allow correct behaviour to be committed in
> each situation, this patch adds a second round of VLAN tag action
> handling to commit_odp_actions(), which occurs after MPLS actions. This
> is implemented with a new field in 'struct xlate_in' called 'vlan_tci'.
> 
> When an push_mpls action is composed, the flow's current VLAN state is
> stored into xin->vlan_tci, and flow->vlan_tci is set to 0 (pop_vlan). If
> a VLAN tag is present, it is stripped; if not, then there is no change.
> Any later modifications to the VLAN state is written to xin->vlan_tci.
> When committing the actions, flow->vlan_tci is used before MPLS actions,
> and xin->vlan_tci is used afterwards. This retains the current datapath
> behaviour, but allows VLAN actions to be applied in a more flexible
> manner.
> 
> Both before and after this patch MPLS LSEs are pushed onto a packet after
> any VLAN tags that may be present. This is the behaviour described in
> OpenFlow 1.1 and 1.2. OpenFlow 1.3 specifies that MPLS LSEs should be
> pushed onto a packet before any VLAN tags that are present. Support
> for this will be added by a subsequent patch that makes use of
> the infrastructure added by this patch.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I think that this patch tries to track the VLAN tag inside the MPLS
label and the VLAN tag outside the MPLS label separately.  But it does
it in an odd way, by testing whether those tags have the same value.
I'm not sure that's correct.  If I set a VLAN, push an MPLS label
outside the VLAN, then push the same VLAN outside the MPLS label, does
it behave correctly?  (Is there a test for this behavior in patch 3?
If so then I'm reassured.)
