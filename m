From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a refcnt
 on port.
Date: Wed, 01 Oct 2014 16:19:41 -0400
Message-ID: <542C61DD.8010504@oracle.com>
References: <20141001185622.GI17706@oracle.com>	 <1412190324.16704.57.camel@edumazet-glaptop2.roam.corp.google.com>	 <20141001194403.GM17706@oracle.com> <1412194526.16704.61.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20952 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbaJAUTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:19:44 -0400
In-Reply-To: <1412194526.16704.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 04:15 PM, Eric Dumazet wrote:
> On Wed, 2014-10-01 at 15:44 -0400, Sowmini Varadhan wrote:
>> On (10/01/14 12:05), Eric Dumazet wrote:
>>>
>>> Hmpff... This calls for rcu protection here !
>>>
>>
>> I did consider that, but given that the lists containing the ports are
>> accessed in multiple contexts, some of which can sleep, and given that
>> the vnet port is similar in spirit to the net_device, I followed the
>> net_device model of dev_put etc.
>
> dev_put() uses per cpu variables, an order of magnitude faster than a
> atomic put/get :(

I could make this a per-cpu variable, it would not be too hard to change
vnet_put/hold etc. That's not a problem.

--Sowmini
