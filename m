From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 13:21:38 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
References: <47ED3F1A.1090101@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38843 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753930AbYC1UVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 16:21:42 -0400
In-Reply-To: <47ED3F1A.1090101@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 28 Mar 2008, Arjan van de Ven wrote:
> 
> Rank 1: input_release_device
> 	This appears to be a regression in 2.6.25; the first reports show up
> in 2.6.25-rc2		Often a warning at kernel/mutex.c:134
> (mutex_lock_nested), but some oopses too

The oopses (at least some of them) seem to be a use-after-free where we 
seem to do a list_add() on an already-released list head (or we didn't 
remove the previous/next entry from a list before we free'd it, and then 
the next list_add() will follow a bogus pointer).

> http://www.kerneloops.org/searchweek.php?search=input_release_device

The problem with kerneloops is that it seems to be really hard to figure 
out the *source* of the oops. I can find the oopses (and it's really good 
with the whole search-and-clump-together-by-version thing), but then when 
some oops like this is found, it's hard to see where your kerneloops 
scripts found the oops from, so the context of the oops is all gone.

Is there something obvious that I'm missing? I'd really like to see the 
whole posting that the oops came from. Do you save the originals or even 
just message ID's from the ones you pick from emails?

		Linus
