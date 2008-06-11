From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 00:10:23 -0700 (PDT)
Message-ID: <20080611.001023.72549734.davem@davemloft.net>
References: <20080610.224023.116817726.davem@davemloft.net>
	<20080611070847.GA4171@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46199
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752386AbYFKHKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 03:10:23 -0400
In-Reply-To: <20080611070847.GA4171@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 11 Jun 2008 07:08:47 +0000

> On 11-06-2008 07:40, David Miller wrote:
> ...
> > Ok, I did an audit of all the drivers under drivers/net that invoke
> > flush_scheduled_work().  Here is my audit analysis and the patch I
> > came up with.  The only deadlock'y case I couldn't fix right now is
> > the cassini driver, see below for details and the patch:
> > 
> > 8139too: Calls flush_scheduled_work() in device remove method, OK.
> 
> I have some doubt here: this rtl8139_thred() work function seems to
> rearm if netif_running(). Is it guaranteed a dev is down while
> running this flush_scheduled_work()?

Indeed, perhaps it should do the flush_scheduled_work()
after the unregister_netdev().
