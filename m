From: David Miller <davem@davemloft.net>
Subject: Re: lockdep trace from rc2.
Date: Tue, 26 Feb 2008 18:13:54 -0800 (PST)
Message-ID: <20080226.181354.33497295.davem@davemloft.net>
References: <20080225022237.GA3907@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42526
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750805AbYB0CNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:13:10 -0500
In-Reply-To: <20080225022237.GA3907@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Sun, 24 Feb 2008 21:22:37 -0500

> https://bugzilla.redhat.com/show_bug.cgi?id=431038 has some more info,
> but the trace is below...
> I'll get an rc3 kernel built and ask the user to retest, but in case this
> isn't a known problem, I'm forwarding this here.

So basically, tulip's ->stop() calls tulip_down() which does a
flush_scheduled_work().

Lockdep is saying that the RTNL mutex (which is held when we
call the driver's ->stop() method) conflicts with that work
queue lock that flush_scheduled_work() takes.

Maybe this has something to do with how linkwatch works, but
I can't say that I've seen this before nor do I quite understand
what lockdep doesn't exactly like here.
