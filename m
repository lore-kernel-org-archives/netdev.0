From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Wed, 16 Dec 2009 21:05:32 -0800
Message-ID: <4B29BC1C.7090800@us.ibm.com>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com> <20091217031539.GA26087@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:37885 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbZLQFFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 00:05:41 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBH52jvP031493
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 22:02:45 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBH55cfm188418
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 22:05:38 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBH55b3T007796
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 22:05:38 -0700
In-Reply-To: <20091217031539.GA26087@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Dec 16, 2009 at 05:43:00PM -0800, Sridhar Samudrala wrote:
>   
>> I had to change virtnet_xmit_poll() to get it working. See below.
>> With this change, i don't see any 'queue full' warnings, but requeues
>> are still happening at the qdisc level (sch_direct_xmit() finds that
>> tx queue is stopped and does requeues).
>>     
>
> Actually this makes no sense.  The queue should only be stopped
> at the end of a xmit run, in which case sch_direct_xmit should
> return 0 so we should never see a requeue.
>   
I think sch_direct_xmit() is not even calling dev_hard_start_xmit() as 
the tx queue is stopped
and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.

> So if we're still seeing requeues then it hasn't been fixed
> properly.
>
> Cheers,
>   


