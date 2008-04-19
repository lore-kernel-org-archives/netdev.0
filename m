From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] tun: vringfd xmit support.
Date: Sat, 19 Apr 2008 10:51:48 -0700
Message-ID: <20080419105148.1bed4fee.akpm@linux-foundation.org>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804190115.15983.rusty@rustcorp.com.au>
	<20080418120634.986e30f1.akpm@linux-foundation.org>
	<200804200041.43969.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53065 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752212AbYDSRvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 13:51:41 -0400
In-Reply-To: <200804200041.43969.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, 20 Apr 2008 00:41:43 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Saturday 19 April 2008 05:06:34 Andrew Morton wrote:
> > On Sat, 19 Apr 2008 01:15:15 +1000 Rusty Russell <rusty@rustcorp.com.au> 
> wrote:
> > > > What is the maximum numbet of pages which an unpriviliged user can
> > > > concurrently pin with this code?
> > >
> > > Since only root can open the tun device, it's currently OK.  The old code
> > > kmalloced and copied: is there some mm-fu reason why pinning userspace
> > > memory is worse?
> >
> > We generally try to avoid it - it allows users to dos the box.
> 
> My question is: is pinning a page worse than allocating a (kernel) page in 
> some way?
> 

I guess pinning is not as bad as straight-out allocating.

Pinning is limited to the size of the program's VM.  Pinning
it at least pining something which is accounted and is exposed
to admin tools.

But they're both pretty similar in effect and risk.
