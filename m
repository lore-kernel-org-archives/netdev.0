From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 10:35:42 -0800
Message-ID: <47A214FE.3050200@hp.com>
References: <20080131124632.GA25299@basil.nowhere.org>	<47A212CB.1060403@hp.com> <20080131190326.GF4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:37132 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbYAaSfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:35:44 -0500
In-Reply-To: <20080131190326.GF4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Thu, Jan 31, 2008 at 10:26:19AM -0800, Rick Jones wrote:
> 
>>Andi Kleen wrote:
>>
>>>TSO interacts badly with many queueing disciplines because they rely on 
>>>reordering packets from different streams and the large TSO packets can 
>>>make this difficult. This patch disables TSO for sockets that send over 
>>>devices with non standard queueing disciplines. That's anything but noop 
>>>or pfifo_fast and pfifo right now.
>>
>>Does this also imply that JumboFrames interacts badly with these qdiscs? 
>> Or IPoIB with its 65000ish byte MTU?
> 
> 
> Correct. Of course it is always relative to the link speed. So if your
> link is 10x faster and your packets 10x bigger you can get similarly
> smooth shaping.

So, at what timescale do people using these qdiscs expect things to 
appear "smooth?"  64KB of data at GbE speeds is something just north of 
half a millisecond unless I've botched my units somewhere.

rick jones
