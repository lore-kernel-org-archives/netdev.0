From: David Miller <davem@davemloft.net>
Subject: Re: q == &noop_qdisc warning from 802.11 code
Date: Wed, 23 Jul 2008 14:22:41 -0700 (PDT)
Message-ID: <20080723.142241.41151635.davem@davemloft.net>
References: <488723FF.8070707@gmail.com>
	<48873502.1030106@linux.vnet.ibm.com>
	<1216824786.13587.6.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, jirislaby@gmail.com,
	netdev@vger.kernel.org, flamingice@sourmilk.net,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756241AbYGWVWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:22:41 -0400
In-Reply-To: <1216824786.13587.6.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 23 Jul 2008 16:53:05 +0200

> 
> > I also hit a bug related to noop_qdisc running the net-next kernel. 
> > I hit this bug every time I run "ifconfig eth0 mtu 9000; ifconfg eth0 1500" for any
> > interface (tested against s2io and e1000) that is up, otherwise the bug isn't
> > reproducible.
> > 
> > The bug dumps the following calltrace: 
> > 
> > [root@io-dolphins net-next-2.6]# ifconfig eth0  mtu 9000; ifconfig eth0 mtu 1500
> > ------------[ cut here ]------------
> > kernel BUG at net/core/dev.c:1328!
> 
> > void __netif_schedule(struct Qdisc *q)
> > {
> >         BUG_ON(q == &noop_qdisc);
> > 
> > So, somehow we're reaching __netif_schedule() using a noop_qdisc. 
> 
> Yeah, I'm looking into it. Just removing the netif_wake calls in mlme.c
> might work.

Don't work too hard on this now, I'm removing the warning as I mentioned
in a recent posting.

Most important is the bug where wireless expects the SKB control block
to be untouched across the qdisc layer, which was never true :-)

