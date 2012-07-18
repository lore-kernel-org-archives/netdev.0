From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: That's pretty much it for 3.5.0
Date: Wed, 18 Jul 2012 09:04:30 -0400
Message-ID: <20120718130430.GE25563@hmsreliant.think-freely.org>
References: <5005D008.6060103@intel.com>
 <20120717.140241.1599386555723262095.davem@davemloft.net>
 <5005E390.7020706@intel.com>
 <20120717.151832.1306978935355646723.davem@davemloft.net>
 <5005F4F9.6010208@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mark.d.rustad@intel.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>,
	h@hmsreliant.think-freely.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50526 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431Ab2GRNEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 09:04:47 -0400
Content-Disposition: inline
In-Reply-To: <5005F4F9.6010208@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 17, 2012 at 04:27:53PM -0700, John Fastabend wrote:
> On 7/17/2012 3:18 PM, David Miller wrote:
> >From: John Fastabend <john.r.fastabend@intel.com>
> >Date: Tue, 17 Jul 2012 15:13:36 -0700
> >
> >>Perhaps the easiest way is to check net->count this should be zero
> >>until setup_net is called.
> >>
> >>if (!atomic_read(&init_net.count))
> >>	return ret;
> >>
> >
> >Won't work, setup_net() runs via a pure_initcall().
> >
> 
> Why not must have missed something? cgroup_init() and
> cgroup_early_init() both run before _initcall() routines are
> called via kernel_init() so this will stop the update in
> netprio from occurring.
> 
> And I don't see any race elsewhere for this.
John, can you post the backtrace you got for this?  I replied to the patch that
you posted for this fix.  the cgroup subsystem has an early_init flag thats
supposed to prevent the initialization of cgroups that don't need initialization
until later (like via module_init() calls).
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
