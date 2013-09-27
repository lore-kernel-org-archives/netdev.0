From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.40 2/7] odp: Allow VLAN actions after MPLS actions
Date: Fri, 27 Sep 2013 12:21:08 -0700
Message-ID: <20130927192108.GA17506@nicira.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-3-git-send-email-horms@verge.net.au>
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
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:58229 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753819Ab3I0TVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 15:21:14 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so3173872pab.36
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 12:21:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380241116-7661-3-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 09:18:31AM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> OpenFlow 1.2 and 1.3 differ on their handling of MPLS actions in the
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
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

The commit message talks about handling OpenFlow 1.2 and 1.3 both
properly, but I don't see how the code distinguishes between the cases.
Can you explain?  Maybe this is something added in a later patch, in
which case it would be nice to mention that in the commit message.

There seems to be a typo in the comment in vlan_tci_restore() here:
> +    /* If MPLS actions were executed after MPLS, copy the final vlan_tci out
> +     * and restore the intermediate VLAN state. */

I was a little confused by the new local variable 'vlan_tci' in
do_xlate_actions().  Partly this was because the fact that I didn't find
it obvious that sometimes it points to different VLAN tags.  I think
this would be easier to see if it were initially assigned just under the
big comment rather than in an initializer, so that one would know to
look at the comment.

Thanks,

Ben.
