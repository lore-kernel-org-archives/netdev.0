From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Wed, 9 Jul 2014 06:49:58 -0400
Message-ID: <20140709104958.GA3784@hmsreliant.think-freely.org>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com>
 <20140708111408.GA23026@hmsreliant.think-freely.org>
 <53BBFAA6.80408@redhat.com>
 <20140708144127.GB23026@hmsreliant.think-freely.org>
 <53BD1211.4080504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48361 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaGIKuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 06:50:20 -0400
Content-Disposition: inline
In-Reply-To: <53BD1211.4080504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2014 at 11:57:37AM +0200, Daniel Borkmann wrote:
> On 07/08/2014 04:41 PM, Neil Horman wrote:
> >On Tue, Jul 08, 2014 at 04:05:26PM +0200, Daniel Borkmann wrote:
> >>On 07/08/2014 01:14 PM, Neil Horman wrote:
> >>...
> >>>since you're adding cmsg's from rfc6458, do you also want to add some
> >>>deprecation warnings around the use of SCTP_SNDRCVINFO too, so we can start to
> >>>schedule its eventual removal?
> >>
> >>Sure, we can do that. Do you want me to include it into the set?
> >
> >If you're plan is to implement 6458, then yes, I think that would be good.
> 
> Looking a bit closer at it, all our pr_warn_ratelimited(DEPRECATED ...)
> warnings in SCTP are being done in 'slowpath' {set,get}sockopt(2) operations
> only, which is fine. What you're suggesting is to place similar ratelimited
> warnings (due to different possible pids on the machine) into the 'fastpath'
> where we get and set cmsg message headers.
> 
> While that may be fine for {set,get}sockopt(2) that's called once or very few
> times, I'm not sure this is a good idea in SCTP_SNDRCVINFO as it will yield
> to unnecessary spamming the klog since up to now this is the only way our
> users can set or receive this info. I'm not sure we want to annoy users like
> that ...
> 
Then we wrap it in a ONCE macro so that it only triggers on the first use
instance.

> In how many years do you plan a removal ... I think we're stuck with uapi
> basically forever as we don't want to break old binaries, no? ;/
> 
I thought we could remove things on a schedule if we followed the deprecation
process, but that may just be for sysfs.  Regardless, it would still be nice to
inform people they are using an older api.

Neil
