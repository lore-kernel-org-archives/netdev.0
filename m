From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 00:17:20 -0700 (PDT)
Message-ID: <20090325.001720.238121238.davem@davemloft.net>
References: <49C380A6.4000904@cosmosbay.com>
	<20090324.234354.43714160.davem@davemloft.net>
	<49C9D99A.2040900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752150AbZCYHRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:17:32 -0400
In-Reply-To: <49C9D99A.2040900@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 25 Mar 2009 08:13:30 +0100

> If done in dev_hard_start_xmit(), skb could be requeued (because of
> NETDEV_TX_BUSY).  Then if requeued, maybe at this time, dst being
> NULL is not a problem ?

Usually it should be OK because the packet schedulers have
a sort-of one-behind state that allows them to reinsert
the SKB into their queue datastructures without reclassifying.

But I'm not %100 sure there isn't some case that might still
need skb->dst there.
