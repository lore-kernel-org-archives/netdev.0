From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.40 5/7] lib: Push MPLS tags in the OpenFlow 1.3
 ordering
Date: Fri, 27 Sep 2013 12:47:19 -0700
Message-ID: <20130927194719.GD17506@nicira.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-6-git-send-email-horms@verge.net.au>
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
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:49424 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753911Ab3I0TrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 15:47:25 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so3003682pdj.26
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 12:47:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380241116-7661-6-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 09:18:34AM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> This patch modifies the push_mpls behaviour to follow the OpenFlow 1.3
> specification in the presence of VLAN tagged packets. From the spec:
> 
> "Newly pushed tags should always be inserted as the outermost tag in the
> outermost valid location for that tag. When a new VLAN tag is pushed, it
> should be the outermost tag inserted, immediately after the Ethernet
> header and before other tags. Likewise, when a new MPLS tag is pushed,
> it should be the outermost tag inserted, immediately after the Ethernet
> header and before other tags."
> 
> When the push_mpls action was inserted using OpenFlow 1.2, we implement
> the previous behaviour by inserting VLAN actions around the MPLS action
> in the odp translation; Pop VLAN tags before committing MPLS actions,
> and push the expected VLAN tag afterwards. The trigger condition for
> this is based on the ofpact->compat field.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Referring to the OF1.2 behavior as "compat behavior" makes the
difference between the two possibilities less clear than otherwise.  I
would prefer to use terminology that makes the distinction obvious.
Perhaps "push mpls before vlan" or "push mpls after vlan" or something
along those lines?

Thanks,

Ben.
