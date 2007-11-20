From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 11:45:54 -0800
Message-ID: <47433972.10903@hp.com>
References: <471E0F3B.2020703@myri.com> <20071119.210919.177660672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, netdev@vger.kernel.org, ossthema@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:39180 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbXKTTqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 14:46:16 -0500
In-Reply-To: <20071119.210919.177660672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Tue, 23 Oct 2007 11:11:55 -0400
> 
> 
>>I've attached a patch which adds support to inet_lro for aggregating
>>pure acks.
> 
> 
> I've applied this patch to net-2.6.25... but!
> 
> This needs some serious thinking.  What this patch ends up doing is creating
> big stretch-ACKs, and those can hurt performance.
> 
> Stretch ACKs are particularly harmful when either the receiver is cpu
> weak (lacking enough cpu power to fill the pipe completely no matter
> what optimizations are applied) or when there is packet loss (less
> feedback information and ACK clocking).
> 
> It also means that the sender will be more bursty, because it will now
> swallow ACKs covering huge portions of the send window, and then have
> large chunks of it's send queue it can send out all at once.
> 
> Fundamentally, I really don't like this change, it batches to the
> point where it begins to erode the natural ACK clocking of TCP, and I
> therefore am very likely to revert it before merging to Linus.

Sounds like one might as well go ahead and implement HP-UX/Solaris-like 
ACK sending avoidance at the receiver and not bother with LRO-ACK on the 
sender.

In some experiements a while back I thought I saw that LRO on the 
receiver was causing him to send fewer ACKs already?  IIRC that was with 
a Myricom card, perhaps I was fooled by it's own ACK LRO it was doing.

rick jones
