From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.42 3/5] lib: Support pushing of MPLS LSE before or
 after VLAN tag
Date: Fri, 4 Oct 2013 09:32:04 -0700
Message-ID: <20131004163204.GI29572@nicira.com>
References: <1380874200-8981-1-git-send-email-horms@verge.net.au>
 <1380874200-8981-4-git-send-email-horms@verge.net.au>
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
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:49695 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754888Ab3JDQcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 12:32:10 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so4420825pab.1
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 09:32:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380874200-8981-4-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 05:09:58PM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> This patch modifies the push_mpls behaviour to allow
> pushing of an MPLS LSE either before any VLAN tag that may be present.
> 
> Pushing the MPLS LSE before any VLAN tag that is present is the
> behaviour specified in OpenFlow 1.3.
> 
> Pushing the MPLS LSE after the any VLAN tag that is present is the
> behaviour specified in OpenFlow 1.1 and 1.2. This is the only behaviour
> that was supported prior to this patch.
> 
> When an push_mpls action has been inserted using OpenFlow 1.2 or earlier
> the behaviour of pushing the MPLS LSE before any VLAN tag that may be
> present is implemented by by inserting VLAN actions around the MPLS push
> action during odp translation; Pop VLAN tags before committing MPLS
> actions, and push the expected VLAN tag afterwards.
> 
> The trigger condition for the two different behaviours is the value of the
> mpls_before_vlan field of struct ofpact_push_mpls.  This field is set when
> parsing OpenFlow actions.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I'm happy with this, I think.  It will need a trivial update if you take
my suggestion on patch 2.
