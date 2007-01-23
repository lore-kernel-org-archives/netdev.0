From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] select: fix sys_select to not leak ERESTARTNOHAND to userspace
Date: Tue, 23 Jan 2007 13:55:08 -0500
Message-ID: <20070123185508.GB582@hmsreliant.homelinux.net>
References: <20070122130020.GA21059@hmsreliant.homelinux.net> <200701231002.49615.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2609 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965391AbXAWS4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 13:56:05 -0500
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200701231002.49615.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 23, 2007 at 10:02:49AM +1100, Andi Kleen wrote:
> On Tuesday 23 January 2007 00:00, Neil Horman wrote:
> > As it is currently written, sys_select checks its return code to convert
> > ERESTARTNOHAND to EINTR.  However, the check is within an if (tvp) clause,
> > and so if select is called from userspace with a NULL timeval, then it is
> > possible for the ERESTARTNOHAND errno to leak into userspace, which is
> > incorrect.  This patch moves that check outside of the conditional, and
> > prevents the errno leak.
> 
> 
> Patch looks good to me.
> 
> -Andi
Thanks for the response, but there is some question as to this patchs validity.
I'm waiting on a reproducer to try and veryify the problem.

Neil

