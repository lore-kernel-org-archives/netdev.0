From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] multiqueue changes
Date: Fri, 09 Oct 2009 00:58:36 -0700 (PDT)
Message-ID: <20091009.005836.201112959.davem@davemloft.net>
References: <20091008090344.GA7409@ff.dom.local>
	<20091008120039.GA8691@ff.dom.local>
	<4ACDD762.9080101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751684AbZJIH6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 03:58:41 -0400
In-Reply-To: <4ACDD762.9080101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Oct 2009 14:13:22 +0200

> I am not sure David intent was being able to dynamically adjust
> real_num_tx_queue between 1 and num_tx_queue.

The idea was to allow semi-dynamic adjustment.

Meaning that you could change the number of TX queues, but only in
some quiescent state, such as when the device is down or frozen while
up in some way.

dev->num_tx_queues tracks how many total were allocated.  This is
necessary so that even if the real_num_tx_queues is modified while the
device is up, we can still see the correct statistics by gathering
from queues that are now disabled but were enabled beforehand.
