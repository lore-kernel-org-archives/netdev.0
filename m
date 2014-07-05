From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] defxx: Fix issues with debug printk calls
Date: Sat, 5 Jul 2014 18:29:35 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407051818370.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1407051520310.15455@eddie.linux-mips.org> <1404578640.6384.49.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:60189 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbaGER3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 13:29:37 -0400
Received: from localhost.localdomain ([127.0.0.1]:48647 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6818711AbaGER3fla0E5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 19:29:35 +0200
In-Reply-To: <1404578640.6384.49.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Jul 2014, Joe Perches wrote:

> > +++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.h
> > @@ -1693,7 +1693,7 @@ typedef union
> >  /* Only execute special print call when debug driver was built */
> >  
> >  #ifdef DEFXX_DEBUG
> > -#define DBG_printk(args...) printk(## args)
> > +#define DBG_printk(args...) printk(args)
> >  #else
> >  #define DBG_printk(args...)
> >  #endif
> 
> It'd be nicer to change this bit to
> 
> #ifdef DEFXX_DEBUG
> #define DBG_printk(fmt, ...)					\
> 	printk(KERN_DEBUG fmt, ##__VA_ARGS__)
> #else
> #define DBG_printk(fmt, ...) 					\
> 	do (if (0) printk(KERN_DEBUG fmt, ##__VA_ARGS__); } while (0)
> #endif
> 
> or just use pr_debug everywhere instead.

 I plan to overhaul this driver to use pr_* or dev_* printk interfaces 
(depending on which of the two I'll find appropriate), but not at this 
stage, here are only strict bug fixes and I don't want to mix bug fixes 
with code quality improvements, so that'd have to be a separate follow-up 
patch anyway (removing DEFXX_DEBUG at the same time as no longer needed).  
This change is at least obviously correct.

 Thanks for your input.

  Maciej
