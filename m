From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1] sch_htb: fix "too many events" situation
Date: Sun, 17 Feb 2008 23:28:29 -0800 (PST)
Message-ID: <20080217.232829.222344360.davem@davemloft.net>
References: <E1JPn6W-0002J2-5x@luxik.cdi.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753267AbYBRH1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 02:27:52 -0500
In-Reply-To: <E1JPn6W-0002J2-5x@luxik.cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>
Date: Fri, 15 Feb 2008 00:02:56 +0100

> From: Martin Devera <devik@cdi.cz>
> 
> HTB is event driven algorithm and part of its work is to apply
> scheduled events at proper times. It tried to defend itself from
> livelock by processing only limited number of events per dequeue.
> Because of faster computers some users already hit this hardcoded
> limit.
> This patch uses loops_per_jiffy variable to limit event processing
> up to single jiffy interval and then delay remainder to other
> jiffy.
> 
> Signed-off-by: Martin Devera <devik@cdi.cz>

I think we would be wise to use something other than loops_per_jiffy.

Depending upon the loop calibration method used by a particular
architecture it can me one of many different things.

Some platforms don't even make use of it and thus leave it at it's
default value of "1<<12", so using it as a heuristic here is arbitrary
at best.
