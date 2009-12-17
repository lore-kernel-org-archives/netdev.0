From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Wed, 16 Dec 2009 22:45:03 -0800
Message-ID: <4B29D36F.5000802@us.ibm.com>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com> <20091217031539.GA26087@gondor.apana.org.au> <4B29BC1C.7090800@us.ibm.com> <20091217062853.GA27734@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:47190 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758572AbZLQGpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 01:45:13 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBH6eG7H004642
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 23:40:16 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBH6j7Z0115592
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 23:45:08 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBH6j7MI027452
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 23:45:07 -0700
In-Reply-To: <20091217062853.GA27734@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Dec 16, 2009 at 09:05:32PM -0800, Sridhar Samudrala wrote:
>   
>> I think sch_direct_xmit() is not even calling dev_hard_start_xmit() as  
>> the tx queue is stopped
>> and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.
>>     
>
> Yes but if the queue was stopped then we shouldn't even get into
> sch_direct_xmit.  
I don't see any checks for txq_stopped in the callers of sch_direct_xmit() :
__dev_xmit_skb() and qdisc_restart().  Both these routines get the txq 
and call
sch_direct_xmit() which checks if tx queue is stopped or frozen.

Am i missing something?

Thanks
Sridhar
> While inside sch_direct_xmit, then only way for
> the queue to be stopped is through dev_hard_start_xmit, and when
> that happens sch_direct_xmit will exit so we should never see a
> requeue if the driver is working properly.
>
> Cheers,
>   


