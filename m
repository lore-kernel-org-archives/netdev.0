From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule
 modifications
Date: Wed, 28 Mar 2007 11:24:17 -0700 (PDT)
Message-ID: <20070328.112417.08322226.davem@davemloft.net>
References: <20070327133845.GM521@postel.suug.ch>
	<20070328111921.GA2703@ff.dom.local>
	<20070328154903.GO521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, netdev@vger.kernel.org, muli@il.ibm.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965636AbXC1SYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 14:24:23 -0400
In-Reply-To: <20070328154903.GO521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 28 Mar 2007 17:49:03 +0200

> * Jarek Poplawski <jarkao2@o2.pl> 2007-03-28 13:19
> > I hope I'm wrong, but isn't this at the cost of admins
> > working with long rules' sets, which (probably) take extra
> > time now?
> 
> That's right, it makes the insert and delete operation more
> expensive.
> 
> A compromise would be to delay the flushing and wait for
> some time (default 2 seconds) whether more rules or routes
> are being added before flushing.

Another idea Thomas and I tossed around was to have some kind of way
for the rule insertion to indicate that the flush should be deferred
and I kind of prefer that explicitness.

By default it's better the flush immediately, because the old
behavior is totally unexpected.  "I insert a rule and it dosn't
show up?", nobody expects that.
