From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: fix BUG during net device "upping"
Date: Sun, 22 Mar 2009 21:21:07 -0700 (PDT)
Message-ID: <20090322.212107.55546529.davem@davemloft.net>
References: <49C61AAA.8050507@gmail.com>
	<1237771258.4231.134.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcin.slusarz@gmail.com, netdev@vger.kernel.org,
	k-keiichi@bx.jp.nec.com, stable@kernel.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49314
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750719AbZCWEVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:21:20 -0400
In-Reply-To: <1237771258.4231.134.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Sun, 22 Mar 2009 20:20:58 -0500

> On Sun, 2009-03-22 at 12:02 +0100, Marcin Slusarz wrote:
> > When ndo_open (eg skge_up) function printks something, netconsole decides
> > it can use this device because it checks state only (netif_running) which is
> > set before ndo_open. Check device flags too.
> 
> That's fairly unfortunate semantics for netif_running. But if Dave
> agrees that it's reasonable for that to be set to true at this point in
> time, then I guess we'll go with it.

These kind of printk's simply are not allowed, we've removed such
printk's from other driver ->open() methods to fix this problem and
that's what should be done here.

I'm rejecting this patch.
