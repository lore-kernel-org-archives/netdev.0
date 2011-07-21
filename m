From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 16:13:01 -0700 (PDT)
Message-ID: <20110721.161301.1825037422957926629.davem@davemloft.net>
References: <4E2781A2.8020905@gont.com.ar>
	<20110721.151750.995903739612693126.davem@davemloft.net>
	<4E28AC3D.1010907@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fernando@gont.com.ar, eric.dumazet@gmail.com, security@kernel.org,
	eugeneteo@kernel.sg, netdev@vger.kernel.org, mpm@selenic.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab1GUXNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 19:13:50 -0400
In-Reply-To: <4E28AC3D.1010907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 21 Jul 2011 15:46:21 -0700

> On 07/21/2011 03:17 PM, David Miller wrote:
>> From: Fernando Gont<fernando@gont.com.ar>
>> Date: Wed, 20 Jul 2011 22:32:18 -0300
>>
>>> Does it make sense to go in this direction rather than simply
>>> randomize
>>> the IPv6 Fragment Identification?
>>
>> We could, but that's actually a bit more work.
>>
>> You have to avoid recycling IDs to the same destination host otherwise
>> a retransmit could use the same ID and overlap with a previous set of
>> frags, causing corruption.
> 
> I think you mean ID reuse rather than packet retransmit no?
> 
> It is the same "frankengram" issue present in IPv4 with its now puny
> 16 bit id field. Doesn't that pretty much rely on layer4 or higher
> checksums to avoid corruption?

We've had documented cases where checksums match after recycling the
fragment ID space in ipv4, that's why we have all of the special
code in the ipv4 fragmentation handling to work around that problem.
