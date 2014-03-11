From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next v2 0/2] gianfar: Tx timeout issue
Date: Tue, 11 Mar 2014 10:10:22 +0200
Message-ID: <531EC4EE.8080104@freescale.com>
References: <1394196166-24932-1-git-send-email-claudiu.manoil@freescale.com> <20140310.131827.672807362272151307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:43768 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751689AbaCKIKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 04:10:33 -0400
In-Reply-To: <20140310.131827.672807362272151307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/2014 7:18 PM, David Miller wrote:
> From: Claudiu Manoil <claudiu.manoil@freescale.com>
> Date: Fri, 7 Mar 2014 14:42:44 +0200
>
>> There's an older Tx timeout issue showing up on etsec2 devices
>> with 2 CPUs.  I pinned this issue down to processing overhead
>> incurred by supporting multiple Tx/Rx rings, as explained in
>> the 2nd patch below.  But before this, there's also a concurency
>> issue leading to Rx/Tx spurrious interrupts, addressed by the
>> 'Tx NAPI' patch below.
>> The Tx timeout can be triggered with multiple Tx flows,
>> 'iperf -c -N 8' commands, on a 2 CPUs etsec2 based (P1020) board.
>
> Series applied, thanks.
>
>

Thanks David.
However there's a problem with the second patch:
http://patchwork.ozlabs.org/patch/327941/
(gianfar: Use Single-Queue polling for "fsl,etsec2")

According to my comments, I retracted the patch because
of null access in gfar_of_init(): priv is not instantiated
at that time, which makes the run time checks (to limit
the number of supported queues) to be tricky.

What do you prefer: an additional separate patch to fix this
null access issue, or to revert the existing patch?

Another point is that the "Use Single-Queue polling..." patch
(http://patchwork.ozlabs.org/patch/327941/)
aims to obsolete the multi-queue polling, i.e. supporting
multiple queues per single NAPI instance.  How do you fill
about removing multi-queue polling support from the driver?
Is there a point for a linux eth driver to support more than
a Rx/Tx queue per NAPI instance?

Thanks again.
Claudiu
