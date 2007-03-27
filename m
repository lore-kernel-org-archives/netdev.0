From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Tue, 27 Mar 2007 16:44:35 -0700 (PDT)
Message-ID: <20070327.164435.123974053.davem@davemloft.net>
References: <46013B73.2060804@trash.net>
	<1174543640.4895.28.camel@localhost>
	<46026A31.1090603@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751349AbXC0XpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 19:45:01 -0400
In-Reply-To: <46026A31.1090603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 22 Mar 2007 12:36:17 +0100

> jamal wrote:
> > The mutex is certainly a cleaner approach;
> > and a lot of the RCU protection would go away. I like it.
> 
> Not as much as I initially thought, but at least we would have
> consistent locking for the dump callbacks.
> 
> > Knowing you i sense theres something clever in there that i am 
> > missing. I dont see how you could get rid of the tree locking
> > since we need to protect against the data path still, no?
> > Or are you looking at that as a separate effort?
> 
> We can remove qdisc_tree_lock since with this patch all changes
> and all tree walking happen under the RTNL. We still need to keep
> dev->queue_lock for the data path.
> 
> I'll update the patches to include all rtnetlink users and repost
> in a day or two.

The existing weird "first SKB only" locking is unintuitive to
me as well, so I'm all for these mutex patches once you respin
them FWIW.
