From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH][net-next] gianfar: Fix alloc_skb_resources on -ENOMEM
 cleanup path
Date: Thu, 8 Nov 2012 17:37:03 +0200
Message-ID: <509BD19F.4080905@freescale.com>
References: <1352382008-7039-1-git-send-email-claudiu.manoil@freescale.com> <509BBFCF.20109@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:38889 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751429Ab2KHPhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 10:37:14 -0500
In-Reply-To: <509BBFCF.20109@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/2012 4:21 PM, Paul Gortmaker wrote:
> On 12-11-08 08:40 AM, Claudiu Manoil wrote:
>> Should gfar_init_bds() return with -ENOMEM inside gfar_alloc_skb_resources(),
>> free_skb_resources() will be called twice in a row on the "cleanup" path,
>> leading to duplicate kfree() calls for rx_|tx_queue->rx_|tx_skbuff resulting
>> in segmentation fault.
>> This patch prevents the segmentation fault to happen in the future
>> (rx_|tx_sbkbuff set to NULL), and corrects the error path handling
>> for gfar_init_bds().
>
> Since gfar_init_bds is more like a slave routine to gfar_alloc_skb_resources,
> I think the dup free_skb_resources should remain in the parent, and be removed
> from gfar_init_bds.  Otherwise the gfar_alloc_skb_resources will appear
> confusing -- one will think it it allocates some resources, hits a failure
> and then returns without bothering to do any cleanup of the parts it
> did manage to allocate. (Then gfar_restore will have to call the free
> itself _if_ gfar_init_bds fails too.)
>
> Paul.

You're right. I'll send the v1 patch shortly.
Thanks.

Claudiu
