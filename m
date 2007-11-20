From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/11] netpoll: remove dev_name for npinfo
Date: Mon, 19 Nov 2007 19:47:50 -0800 (PST)
Message-ID: <20071119.194750.34466046.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.747306412@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752400AbXKTDrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 22:47:51 -0500
In-Reply-To: <20071103184338.747306412@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:20 -0700

> The device name was only in npinfo for netconsole target
> configuration, so move it to netconsole.  Netconsole only
> needs the value during config, so no need to do all
> the device name tracking etc.. 
> 
> Make functions for common code for instantiation and 
> start up.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Sigh...

	return -EUNTESTED;

In netpoll_parse_options() np->dev isn't setup yet, so if you had
tested this patch you would have gotten an immediate OOPS.

That's why it needs the npinfo->dev_name in the first place, because
it has to be parsed in order to even know what device to attach to.
The np->dev usually isn't setup until netpoll_setup() is called.

I appreciate all the work you are doing trying to clean up this beast
but you have to start testing this stuff and audit the transformations
you are making, instead of always relying on me or someone else to do
it for you.

That's why I let these particular patches sit in my inbox for two
weeks, I knew half of them would have bugs and most if not all of them
were totally untested, so I dreaded reviewing them.

I might have to toss some of the rest of these netconsole things
if there are dependencies on this bogus change.
