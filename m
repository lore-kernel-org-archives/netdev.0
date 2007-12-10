From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc4-mm1
Date: Mon, 10 Dec 2007 13:11:35 -0800
Message-ID: <20071210131135.855118f5.akpm@linux-foundation.org>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
	<475D51C7.6010809@reub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Reuben Farrelly <reuben-linuxkernel@reub.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54611 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752246AbXLJVLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 16:11:43 -0500
In-Reply-To: <475D51C7.6010809@reub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007 01:48:39 +1100
Reuben Farrelly <reuben-linuxkernel@reub.net> wrote:

> 
> 
> On 5/12/2007 4:17 PM, Andrew Morton wrote:
> > Temporarily at
> > 
> >   http://userweb.kernel.org/~akpm/2.6.24-rc4-mm1/
> > 
> > Will appear later at
> > 
> >   ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc4/2.6.24-rc4-mm1/
> > 
> > 
> > - Lots of device IDs have been removed from the e1000 driver and moved over
> >   to e1000e.  So if your e1000 stops working, you forgot to set CONFIG_E1000E.
> > 
> > - The s390 build is still broken.
> 
> I'm seeing this most incredibly unhelpful (to debug) but fortunately
> reproduceable problem (so far 4/4 times) on this -mm kernel.  I thought this 
> problem may have been related to another bug which I have reported (A TCP oops) 
> but even after applying a likely fix for that I am still seeing this problem.
> 
> The machine boots up perfectly fine and runs good until I load it up.
> In this case I can reliably cause this to occur by pulling a 3G ISO across the
> GigE network from my Linux box to my PC.  After maybe 50M or so, the console 
> just displays this (ignore initial boot banner):
> 
> ----------
> 
>   * Starting local ...                                                     [ ok ]
> 
> 
> This is tornado.reub.net (Linux x86_64 2.6.24-rc4-mm1) 00:24:01
> 
> tornado login: *** buffer overf
> 
> -------
> 
> Yes - after displaying the 'f' in what I can only guess is the word 'overflow',
> the box spontaneously reboots.  There is no further console output until it 
> starts to come back up again.
> 
> The problem does not exist in 2.6.23-gentoo kernels nor in a vanilla 
> 2.6.24-rc4-git6 (phew!), so this looks to be an -mm only problem at this stage.
> 
> I enabled a number of kernel debugging options but then I got no output at all 
> when the machine crashed.
> 
> I'm at a bit of a loss as to which subsystem this might be coming from, so I'm 
> not sure who to CC.
> 
> Box information is (still) up at http://www.reub.net/files/kernel/2.6.24-rc4-mm1/
> 

hm.  grepping around for "buffer overflow" doesn't turn up anything except in
drivers which you won't be using on that machine.

I'd be suspecting networking, obviously.  If you're feeling keen could you please
grep a 2.6.24-rc4 tree and apply 2.6.24-rc4-mm1's origin.patch and git-net.patch
and see if the bug is still present?
