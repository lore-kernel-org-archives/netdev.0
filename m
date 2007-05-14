From: David Miller <davem@davemloft.net>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Sun, 13 May 2007 23:39:37 -0700 (PDT)
Message-ID: <20070513.233937.99203647.davem@davemloft.net>
References: <20070511.140309.59656886.davem@davemloft.net>
	<20070511141225.cf7a6909.akpm@linux-foundation.org>
	<20070514060700.GA1000@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58053
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753221AbXENGjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 02:39:46 -0400
In-Reply-To: <20070514060700.GA1000@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 14 May 2007 08:07:00 +0200

> After sending this patch I was a little confused, when next
> lockdep warning report appeared, and I thought - since this is 
> not enough, this patch could be dumped. But now I changed my
> mind: there are really many possibilities of strange connections
> between locks taken from vlans, ppp (with pppoe), multicasts etc.
> - that every one possibility less is a gain here.
 ...
> Of course, later, if somebody will find better solution, they could
> be removed,

I already suggested a better fix, you ignored it.

For each unique netdev type, use a different locking class.

That will fix this forever, anything else is a situation specific
band-aid (but then again isn't that what every lockdep annotation is
:-).
