From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] net: Have xmit_list() signal more==true when
 appropriate.
Date: Tue, 02 Sep 2014 13:55:15 -0700 (PDT)
Message-ID: <20140902.135515.1879196973068806729.davem@davemloft.net>
References: <20140901.152459.592105486574617399.davem@davemloft.net>
	<20140902092538.7987db64@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583AbaIBUzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:55:16 -0400
In-Reply-To: <20140902092538.7987db64@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 2 Sep 2014 09:25:38 +0200

> On Mon, 01 Sep 2014 15:24:59 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
>>  		if (unlikely(!dev_xmit_complete(rc))) {
>>  			skb->next = next;
>>  			goto out;
> 
> In the exit case (!dev_xmit_complete(rc)) is it,
> 1. the responsibility of the driver to "flush" the tail, or
> 2. do we depend on qdisc or softirq to be reactivated soonish?

I think the driver will have to do it, much like it must do so when
the queue is stopped.
