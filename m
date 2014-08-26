From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Mon, 25 Aug 2014 21:50:11 -0700 (PDT)
Message-ID: <20140825.215011.2154860869917151848.davem@davemloft.net>
References: <20140825.163502.973913220915588977.davem@davemloft.net>
	<CA+mtBx9kwbw=XNhQMRjHhnh8PRjy1A93MPPST6bwdMpXjz7YjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754375AbaHZEuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 00:50:15 -0400
In-Reply-To: <CA+mtBx9kwbw=XNhQMRjHhnh8PRjy1A93MPPST6bwdMpXjz7YjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 25 Aug 2014 20:42:59 -0700

> I would suggest the flush should be done if !skb->xmit_more or queue
> is being stopped. So maybe pull this code into it's own function e.g.
> igb_flush(tx_ring). Then do:
> 
> if (igb_maybe_stop_tx(tx_ring, DESC_NEEDED) || !skb->more)
>    igb_flush(tx_ring);

Agreed, and we will need to sort this out in all cases before we start
actually doing real deferral by setting skb->xmit_more.
