From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 13:41:31 -0700 (PDT)
Message-ID: <20070827.134131.41639376.davem@davemloft.net>
References: <1187808408.4314.15.camel@johannes.berg>
	<1188086976.18004.5.camel@localhost>
	<1188212049.6756.18.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759240AbXH0Ulf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 16:41:35 -0400
In-Reply-To: <1188212049.6756.18.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 27 Aug 2007 12:54:09 +0200

> -- change macros to --
> #define MAC_FMT "%s"
> #define MAC_ARG(a) ({char __buf[18]; print_mac(a, buf); __buf})
> 
> I'm not sure we'd want that, but at the time you said it made the kernel
> significantly smaller and I doubt there's a performance problem with it
> (who prints mac addresses regularly?)

I don't think this works.

The scope of the __buf[18] array is inside of that MAC_ARG()
expression, which will be fully evaluated before constructing
the argument to printk().

Therefore printk() will be passed what is essentially a stale stack
pointer.

You'd need something like a "MAC_BUF buf;" all the callers need
to declare, and a new "buf" argument to MAC_ARG().

If this was the goal, there are better approches to this, how
about just calling:

	print_mac(dev->dev_addr);

Sure, we'll have to split up printk() calls, but in the end it's
likely still smaller and better.  And I think it's much cleaner
than this macro stuff.

