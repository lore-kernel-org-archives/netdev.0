From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/5] sky2: add fake idle irq timer
Date: Wed, 26 Apr 2006 00:39:00 +0200
Message-ID: <20060425223900.GB18035@electric-eye.fr.zoreil.com>
References: <20060425175849.372221000@localhost.localdomain> <20060425175951.444629000@localhost.localdomain> <20060425212329.GA18035@electric-eye.fr.zoreil.com> <20060425143042.29d636a8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:4062 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751628AbWDYWje
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 18:39:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060425143042.29d636a8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> > Any objection against moving mod_timer() from sky2_poll() to sky2_idle()
> > so as to keep poll() path unmodified ?
> > 
> 
> If traffic is moving, then I want the timer to keep getting rescheduled
> farther out.

If my version of the driver is not stale, the timer will not be
rescheduled when work_done >= work_limit. I.e. the optimization
tends to vanish when the load goes up. Before this point is reached,
the long path of mod_timer() can be taken up to HZ per second.

I have no idea which balance works best.

-- 
Ueimor
