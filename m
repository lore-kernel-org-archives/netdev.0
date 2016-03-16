From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 not bringing up due to qdisc_tx_is_noop failing
Date: Wed, 16 Mar 2016 18:18:41 +0100
Message-ID: <56E99571.8080209@stressinduktion.org>
References: <56E97BEA.4070004@kyup.com> <56E992E0.1080708@stressinduktion.org>
 <CAJFSNy6Kz8yYWk4J9wHqbkhBoPcjG=rZ89mTDMQ=66njaH9Wag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33232 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751498AbcCPRSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:18:45 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id E58A020DD6
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 13:18:44 -0400 (EDT)
In-Reply-To: <CAJFSNy6Kz8yYWk4J9wHqbkhBoPcjG=rZ89mTDMQ=66njaH9Wag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.03.2016 18:14, Nikolay Borisov wrote:
> On Wed, Mar 16, 2016 at 7:07 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 16.03.2016 16:29, Nikolay Borisov wrote:
>>>
>>> I have stack traces which do show this sequence of events, so my
>>> questions now are:
>>>
>>> 1. What's the difference between netdev_queue->qdisc and
>>> netdev_queue->qdisc_sleeping. Git blaming indicates those member haves
>>> existed even before the git history was started.
>>
>> qdisc_sleeping is the qdisc you configure before the device is brought up.
>> It should transition during carrier up to the normal qdisc.
>>
>>> 2. Shouldn't the netdev_queue->qdisc also be updated during
>>> attach_one_default_qdisc?
>>
>> Yes, do you have carrier up on your card?
>
> Actually no, the interface indeed shows no carrier yet ibping to other
> hosts on the infiniband network works and ibstats shows the link as
> being in up state. Do you have any ideas how to debug this further?

Probably something in the driver should call netif_carrier_on if carrier 
is connectivity is available. I don't have enough knowledge about IB how 
carrier detection is done there.

>> Is this a regression, did this work for you and stopped working with a
>> specific kernel version?
>
> I don't think this is a regression.

Okay, thanks.

Bye,
Hannes
