From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.40 4/7] ofp-actions: Add separate OpenFlow 1.3 action
 parser
Date: Fri, 27 Sep 2013 12:41:19 -0700
Message-ID: <20130927194119.GC17506@nicira.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-5-git-send-email-horms@verge.net.au>
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
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:41079 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753731Ab3I0TlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 15:41:25 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so3038592pdi.28
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 12:41:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380241116-7661-5-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 09:18:33AM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> This patch adds new ofpact_from_openflow13() and
> ofpacts_from_openflow13() functions parallel to the existing ofpact
> handling code. In the OpenFlow 1.3 version, push_mpls is handled
> differently, but all other actions are handled by the existing code.
> 
> For push_mpls, ofpact_push_mpls.ofpact.compat is set to
> OFPUTIL_OFPAT13_PUSH_MPLS, which allows correct VLAN+MPLS datapath
> behaviour to be determined at odp translation time.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I am nervous about this idea of having ofpacts_pull_openflow11_actions()
and ofpacts_pull_openflow11_instructions() try to figure out what
version of OpenFlow is involved.  It is a new and somewhat surprising
requirements that the callers provide not just actions or instructions
but a complete OpenFlow message.  I see that the callers in ovs-ofctl.c
don't satisfy this requirement.

I think that it would be better to make these functions' callers say
what version of OpenFlow they are working with.  One could provide a
helper function like get_version_from_ofpbuf(), which should probably go
in ofp-util.c, but I would want it to fail (assert-fail or segfault or
whatever) if there is no L2 header pointer, instead of returning a
default value (that, in this case anyway, we know must be wrong because
OF1.0 never contains OF1.1+ actions or instructions).

Thanks,

Ben.
