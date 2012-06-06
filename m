From: David Miller <davem@davemloft.net>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 06 Jun 2012 11:51:30 -0700 (PDT)
Message-ID: <20120606.115130.1091814494251887552.davem@davemloft.net>
References: <jqo7op$t6f$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: grant.b.edwards@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513Ab2FFSvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 14:51:31 -0400
In-Reply-To: <jqo7op$t6f$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Edwards <grant.b.edwards@gmail.com>
Date: Wed, 6 Jun 2012 18:32:57 +0000 (UTC)

> The kernel module that's started failing fills the allocated sk_buff
> until tailroom() indicates it is full and then sends it.  The problem
> is that sending a packet with a length of 1850 won't work (it's a
> MAC-layer Ethernet packet).

The amount of tailroom an SKB has is implementation dependent.

It's incredibly poor form to rely upon it to determine whether a fully
sized frame has been constructed or not.

Please fix the code that does this.
