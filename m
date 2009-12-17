From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 11:27:55 +0000
Message-ID: <20091217112754.GA7755@ff.dom.local>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:64204 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964967AbZLQL17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 06:27:59 -0500
Received: by fxm21 with SMTP id 21so1784967fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 03:27:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-12-2009 11:03, Krishna Kumar2 wrote:
>> Sridhar Samudrala <sri@us.ibm.com>
>>
>> Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
>>
>> Herbert Xu wrote:
>>> On Wed, Dec 16, 2009 at 09:05:32PM -0800, Sridhar Samudrala wrote:
>>>
>>>> I think sch_direct_xmit() is not even calling dev_hard_start_xmit() as
> 
>>>> the tx queue is stopped
>>>> and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.
>>>>
>>> Yes but if the queue was stopped then we shouldn't even get into
>>> sch_direct_xmit.
>> I don't see any checks for txq_stopped in the callers of
> sch_direct_xmit() :
>> __dev_xmit_skb() and qdisc_restart().  Both these routines get the txq
>> and call
>> sch_direct_xmit() which checks if tx queue is stopped or frozen.
>>
>> Am i missing something?
> 
> Yes - dequeue_skb.
> 
> The final skb, before the queue was stopped, is transmitted by
> the driver. The next time sch_direct_xmit is called, it gets a
> skb and finds the device is stopped and requeue's the skb.

So we _should_ get into sch_direct_xmit when the queue was stopped...
I guess Herbert might forget the multiqueue change, and Sridhar isn't
missing much. ;-)

Thanks,
Jarek P.
