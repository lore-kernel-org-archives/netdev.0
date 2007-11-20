From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LRO ack aggregation
Date: Mon, 19 Nov 2007 21:09:19 -0800 (PST)
Message-ID: <20071119.210919.177660672.davem@davemloft.net>
References: <471E0F3B.2020703@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ossthema@de.ibm.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751766AbXKTFJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:09:20 -0500
In-Reply-To: <471E0F3B.2020703@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 23 Oct 2007 11:11:55 -0400

> I've attached a patch which adds support to inet_lro for aggregating
> pure acks.

I've applied this patch to net-2.6.25... but!

This needs some serious thinking.  What this patch ends up doing is creating
big stretch-ACKs, and those can hurt performance.

Stretch ACKs are particularly harmful when either the receiver is cpu
weak (lacking enough cpu power to fill the pipe completely no matter
what optimizations are applied) or when there is packet loss (less
feedback information and ACK clocking).

It also means that the sender will be more bursty, because it will now
swallow ACKs covering huge portions of the send window, and then have
large chunks of it's send queue it can send out all at once.

Fundamentally, I really don't like this change, it batches to the
point where it begins to erode the natural ACK clocking of TCP, and I
therefore am very likely to revert it before merging to Linus.
