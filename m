From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/6] atl1c: remove private tx lock
Date: Tue, 26 Apr 2016 01:16:42 +0200
Message-ID: <20160425231642.GA20830@electric-eye.fr.zoreil.com>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
 <1461526694-11367-3-git-send-email-fw@strlen.de>
 <20160424220529.GA29377@electric-eye.fr.zoreil.com>
 <20160425154339.GA17538@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58430 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbcDYXQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 19:16:48 -0400
Content-Disposition: inline
In-Reply-To: <20160425154339.GA17538@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> :
> Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> > Play it safe and keep the implicit local_irq_{save / restore} call ?
> > 
> > It may not be needed but it will help avoiding any unexpected regression
> > report pointing at the NETDEV_TX_LOCKED removal change.
> 
> I thought about that but it doesn't prevent the irq handler from
> running on another CPU, so leaving it around seemed like cargo culting
> to me...

I don't mind removing it in a different patch at all. I'd rather see
the commit history underline that it's unrelated to whatever
NETDEV_TX_LOCKED / LLTX change.

> I don't have an atl1c, but the atl1e in my laptop seems to work fine
> with the (similar) change.
> 
> If you disagree I can respin with local_irq_save of course, but, if
> 'playing it safe' is main goal then its simpler to convert
> spin_trylock_irqsave to spin_lock_irqsave.

Your call, really.

-- 
Ueimor
