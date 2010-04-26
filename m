From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Sun, 25 Apr 2010 23:27:58 -0700 (PDT)
Message-ID: <20100425.232758.101478192.davem@davemloft.net>
References: <1272258841.2069.968.camel@edumazet-laptop>
	<q2w412e6f7f1004252244s3a5000eft850c2a5dc0fd72d1@mail.gmail.com>
	<1272262154.2069.1032.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751586Ab0DZG1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 02:27:53 -0400
In-Reply-To: <1272262154.2069.1032.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Apr 2010 08:09:14 +0200

> LIFO is the slub behavior, for the exact reason its better for cache
> reuse. Same for completion queue.
> 
> I repeat : 
> - slub dont touch objects in normal situations.
> - LIFO is better for caches.
> - LIFO is faster (one pointer for the queue head)

No matter what is faster, we have to process packets in
FIFO order, otherwise we get reordering within a flow
which is to be absolutely avoided.
