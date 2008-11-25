From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_api: Remove qdisc_list_lock
Date: Tue, 25 Nov 2008 13:56:22 -0800 (PST)
Message-ID: <20081125.135622.231076050.davem@davemloft.net>
References: <20081125112941.GA8136@ff.dom.local>
	<492BE515.1080703@trash.net>
	<492BE591.8060202@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750998AbYKYV4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 16:56:22 -0500
In-Reply-To: <492BE591.8060202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 25 Nov 2008 12:46:25 +0100

> Patrick McHardy wrote:
> > Jarek Poplawski wrote:
> >> After implementing qdisc->ops->peek() there is no more calling
> >> qdisc_tree_decrease_qlen() without rtnl_lock(), so qdisc_list_lock
> >> added by commit: f6e0b239a2657ea8cb67f0d83d0bfdbfd19a481b "pkt_sched:
> >> Fix qdisc list locking" can be removed.
> > I might be misunderstanding something, but qdisc_tree_decrease_qlen()
> > doesn't need rtnl_lock() but the sch_tree_lock() since it changes
> > q.qlen.
> 
> OK I see now, rtnl_lock() was taken to protect the parent qdisc lookup.
> In that case it seems fine, all callers are holding both sch_tree_lock()
> and rtnl_lock().

:-)

I've applied Jarek's patch.

Thanks!
