From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next] sched: remove NET_XMIT_POLICED
Date: Sat, 11 Jun 2016 11:06:05 +0200
Message-ID: <20160611090605.GA3669@breakpoint.cc>
References: <1465561289-15401-1-git-send-email-fw@strlen.de>
 <20160610.233137.888795126611100309.davem@davemloft.net>
 <20160611.000047.2179423929953796335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, a@unstable.cc,
	sw@simonwunderlich.de, mareklindner@neomailbox.ch,
	sven@narfation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37679 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750929AbcFKJGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 05:06:12 -0400
Content-Disposition: inline
In-Reply-To: <20160611.000047.2179423929953796335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> I have to revert this, the sch_atm.c change is wrong.
> 
> NET_XMIT_POLICED is the default value of 'ret' which can be used
> if we branch to 'drop'.  So now GCC says that 'ret' might be used
> uninitialized.

Hmpf, seems I need to update gcc :-|

> So it is actually used, and reported by sch_atm when TC_ACT_SHOT
> classifications occur.

I'll resubmit a v2 changing initializer to NET_XMIT_DROP.
