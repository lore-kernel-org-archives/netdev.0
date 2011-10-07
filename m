From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Fri, 07 Oct 2011 20:42:12 +0200
Message-ID: <1318012932.3974.7.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
	 <1318009222.3988.28.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:39318 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896Ab1JGSmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 14:42:16 -0400
In-Reply-To: <1318009222.3988.28.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-07 at 19:40 +0200, Johannes Berg wrote:

> > It looks like skb_clone_tx_timestamp() sets clone->sk without any
> > proper refcounting, so I bet this NULL'ing it out is working
> > around that bug.
> 
> You're right. But this bug can actually trigger another way: The only
> user of this is dp83640_txtstamp() which might do kfree_skb() on this
> skb, in which case that'll likely crash trying to clean up the sk.

Maybe that's how you can trigger it: have one thread turn on and off
timestamping all the time, and another thread send frames all the time,
then eventually you'll probably run into the kfree_skb() case there. If
you ever manage to run into that case, it'll crash either when freeing
this skb or when freeing the original.

Anyway, it's broken. I'll stop thinking about it. You (Richard) should
fix it quickly though otherwise I think we should revert/delete this
code.

johannes
