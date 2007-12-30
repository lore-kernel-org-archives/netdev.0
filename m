From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][ROSE][AX25] af_ax25: possible circular locking
Date: Sun, 30 Dec 2007 15:13:23 +0100
Message-ID: <20071230141323.GA3377@ami.dom.local>
References: <20071218135202.GA2023@ff.dom.local> <47755FDB.2070501@free.fr> <20071228214857.GA3290@ami.dom.local> <20071229.191443.10947724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f6bvp@free.fr, ralf@linux-mips.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:2019 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450AbXL3OKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 09:10:50 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2410094fga.17
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2007 06:10:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071229.191443.10947724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2007 at 07:14:43PM -0800, David Miller wrote:
...
> You can't just drop this linked list lock and expect it to stay
> consistent like that.
> 
> Once you drop it, any thread of control can get in there and delete
> entries from the list.
> 
> Since we know it can happen, using a WARN_ON_ONCE(1) is not
> appropriate.

The problem is 'we' don't know if it can happen... In the first
message with this patch I've tried to get this information, and
now it seems you are the only one with this knowledge, but of
course this is more than enough for me to agree with your decision
to dump this patch.

> [...]  And if it triggers it will do the wrong thing, because
> by branching back to "again" we can call ax25_disconnect() multiple
> times on the same entry which isn't right.

This is an equivalent of list_for_each_entry_safe(), and if such
WARN_ON is ever reported this would confirm the solution is wrong.
But, it seems Bernard's case was too simple to trigger this bug.
Alas it was complex enough to trigger this other bug...

"again" loop should skip this entry next time: s->ax25_dev should
be NULL, so not equal to ax25dev. (But of course there could be
this unknown to me place, which changes this back in the meantime.)

> You'll thus need to resolve this locking conflict more properly.
> I know it's hard, but your current fix is worse because it adds
> a new known bug.

Sorry, it seems this will've to wait until Ralf finds some time,
because I really can't give this more time, considering I never
used nor have any plans to use this code, and this bug could
suggest there is not so many interested in this, besides Bernard,
either.

Regards,
Jarek P.
