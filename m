From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Wed, 01 Oct 2014 16:15:08 -0400 (EDT)
Message-ID: <20141001.161508.1823792090990427608.davem@davemloft.net>
References: <20141001185604.GG17706@oracle.com>
	<20141001.155009.2277009117294992988.davem@davemloft.net>
	<542C5C37.1040409@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaJAUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:15:12 -0400
In-Reply-To: <542C5C37.1040409@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 01 Oct 2014 15:55:35 -0400

> On 10/01/2014 03:50 PM, David Miller wrote:
> 
>>>
>>>     A BH Rx handler is a simpler way to avoid the weaknesses of processing
>>>     packets in LDC interrupt context, and also provides Rx load-spreading
>>>     across multiple CPUs.
>>
>> I think you want to re-evaluate this considering napi_gro_receive()
>> which
>> is what you should really be calling in a NAPI driver.
> 
> 
> Sorry I dont follow the suggestion.
> 
> If I make this a NAPI driver that uses napi_gro_receive, I would
> still have to deal with a budget, right?

Absolutely, and YOU MUST, because the budget keeps one device from
hogging the RX packet input path from other devices on a given cpu.
