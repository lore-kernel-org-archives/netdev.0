From: David Miller <davem@davemloft.net>
Subject: Re: lockdep trace from rc2.
Date: Tue, 26 Feb 2008 22:40:10 -0800 (PST)
Message-ID: <20080226.224010.227576469.davem@davemloft.net>
References: <20080226.181354.33497295.davem@davemloft.net>
	<20080226195157.46645a62@extreme>
	<20080226195400.3f6e010b@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751360AbYB0GkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 01:40:10 -0500
In-Reply-To: <20080226195400.3f6e010b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 26 Feb 2008 19:54:00 -0800

> > This has come up before in other drivers,
> > you can't call flush_scheduled_work under RTNL.
> 
> Correct link: http://kerneltrap.org/mailarchive/linux-kernel/2007/4/11/76312

Ok.

When I first looked at Dave's lockdep trace I grepped around and there
are a bunch of drivers that call flush_scheduled_work like this.

It seems that the common case is a driver that shares a lot of code
between the suspend and ->stop paths.  Tulip is just such a case.

I can't tell if it's legal to just move the flush_scheduled_work()
call out of tulip_down() and into it's suspend function.  If it
needs this for suspend it probably needs it for ->stop() too.

Maybe it could do something similar to the 8139too fix at the above
URL, but this is quite cumbersome if you ask me.

Anyways, could someone please work on a fix for this stuff?
