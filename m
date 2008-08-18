From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 02:31:05 -0700 (PDT)
Message-ID: <20080818.023105.01989851.davem@davemloft.net>
References: <20080818.013954.187452037.davem@davemloft.net>
	<20080818091011.GC5434@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751368AbYHRJbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 05:31:05 -0400
In-Reply-To: <20080818091011.GC5434@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 09:10:12 +0000

> Yes, this was one of the reasons, but not the only one, and my oldbie
> version of this fix could be found here as "02-fix1.patch":
> 
> http://permalink.gmane.org/gmane.linux.network/103039

This is what I get for failing to be able to follow that
flurry of patches :)  I'll apply your version in the
end, thanks.

> It's a bit different, because I think wd->qdisc can probably
> point to the noop_qdisc (if it's the root qdisc).

noop_qdisc does not use the watchdogs as far as I can see.

But, if we are in dev_deactivate() state, root qdisc can
be &noop_qdisc and scheduling that is fine and just a nop.

> Anyway this kind of change is necessary here, and everywhere where
> netif_schedule() could be called (I've found sch_cbq.c only).

Indeed.

I can't find any other cases that would matter.
