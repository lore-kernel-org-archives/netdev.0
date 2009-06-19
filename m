From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC net 02/03]: allow to propagate errors through	->ndo_hard_start_xmit()
Date: Fri, 19 Jun 2009 14:23:25 +0200
Message-ID: <4A3B833D.6040604@trash.net>
References: <20090616092531.GA6106@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65308 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117AbZFSMXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 08:23:25 -0400
In-Reply-To: <20090616092531.GA6106@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 09-06-2009 18:17, Patrick McHardy wrote:
>> commit c2104095c3a1023b4f4809c90092145dff093c88
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Tue Jun 9 17:55:34 2009 +0200
>>
>>     net: allow to propagate errors through ->ndo_hard_start_xmit()
>>     
> ...
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 11560e3..b2e9953 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1731,6 +1731,8 @@ gso:
>>  		nskb->next = NULL;
>>  		rc = ops->ndo_start_xmit(nskb, dev);
>>  		if (unlikely(rc)) {
>> +			if (rc & ~NETDEV_TX_MASK)
>> +				return rc;
> 
> This is probably not enough: what about the rest of the skb
> (qdisc_restart() would skip requeuing)?

Good point, I guess we should drop the remaining parts.
I'll fix that up, thanks.
