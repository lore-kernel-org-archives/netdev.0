From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/21] drivers/net/3c501.c: replace
 init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 15:07:10 -0700
Message-ID: <20080328150710.6a664440.akpm@linux-foundation.org>
References: <200803282141.m2SLfGGa011804@imap1.linux-foundation.org>
	<20080328214755.GE10722@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jkschind@gmail.com
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36497 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755766AbYC1WHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 18:07:45 -0400
In-Reply-To: <20080328214755.GE10722@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 21:47:55 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Fri, Mar 28, 2008 at 02:41:16PM -0700, akpm@linux-foundation.org wrote:
> 
> > Replace init_module and cleanup_module with static functions and
> > module_init/module_exit.
> 
> Would the esteemed sir bother to build the resulting tree with drivers
> in question non-modular?
> 
> Damnit, people, try to think for a minute.  If these functions were
> not called directly in non-modular case, the driver would not work
> built-in.  Which is not apriori impossible, but might warrant some
> further investigation.  Use of grep, for starters...
> 

well...  The probe functions are still called, only they're now called at
initcall-time as well as from the infamous Space.c.

So I guess these patches should at least have removed the calls from
Space.c tables, but iirc things aren't as simple as that.  I don't remember
why.

> IOW, please unapply the patches in question.

always happy to do that.
