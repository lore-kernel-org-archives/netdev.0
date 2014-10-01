From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a
 refcnt on port.
Date: Wed, 01 Oct 2014 16:24:31 -0400 (EDT)
Message-ID: <20141001.162431.2179338820333183894.davem@davemloft.net>
References: <20141001194403.GM17706@oracle.com>
	<1412194526.16704.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<542C61DD.8010504@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbaJAUYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:24:34 -0400
In-Reply-To: <542C61DD.8010504@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 01 Oct 2014 16:19:41 -0400

> On 10/01/2014 04:15 PM, Eric Dumazet wrote:
>> On Wed, 2014-10-01 at 15:44 -0400, Sowmini Varadhan wrote:
>>> On (10/01/14 12:05), Eric Dumazet wrote:
>>>>
>>>> Hmpff... This calls for rcu protection here !
>>>>
>>>
>>> I did consider that, but given that the lists containing the ports are
>>> accessed in multiple contexts, some of which can sleep, and given that
>>> the vnet port is similar in spirit to the net_device, I followed the
>>> net_device model of dev_put etc.
>>
>> dev_put() uses per cpu variables, an order of magnitude faster than a
>> atomic put/get :(
> 
> I could make this a per-cpu variable, it would not be too hard to
> change
> vnet_put/hold etc. That's not a problem.

If you went with NAPI you could use RCU.

All of the negative and complicated aspects of your changes strictly
have to do with not going with that implementation route.
