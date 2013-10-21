From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.44 2/5] ofp-actions: Add separate OpenFlow 1.3 action
 parser
Date: Mon, 21 Oct 2013 13:19:45 -0700
Message-ID: <20131021201945.GC15986@nicira.com>
References: <1381972511-27221-1-git-send-email-horms@verge.net.au>
 <1381972511-27221-3-git-send-email-horms@verge.net.au>
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
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:37166 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751015Ab3JUUTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 16:19:53 -0400
Received: by mail-qa0-f46.google.com with SMTP id j15so2793040qaq.19
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 13:19:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1381972511-27221-3-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 10:15:08AM +0900, Simon Horman wrote:
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
> enum ofpact_mpls_position contributed by Ben Pfaff.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I applied this commit to master, but I changed the commit message to:

>From a7a2d006baae4152d338bd0bb4de1687084b1b07 Mon Sep 17 00:00:00 2001
From: Joe Stringer <joe@wand.net.nz>
Date: Thu, 17 Oct 2013 10:15:08 +0900
Subject: [PATCH] ofp-actions: Distinguish OF1.1/1.2 push_mpls from OF1.3+.

In OpenFlow 1.1 and 1.2, the push_mpls action pushes the MPLS label after
any existing VLAN tag.  In OpenFlow 1.3, it pushes the label before any
existing VLAN tag.  Until now, the action parser didn't distinguish these
cases.  This commit adds support.  Nothing yet actually changes the
behavior of push_mpls.

enum ofpact_mpls_position contributed by Ben Pfaff.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Ben Pfaff <blp@nicira.com>
