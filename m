From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2: allocate with GFP_KERNEL flag on RX path init
Date: Thu, 15 Jul 2010 20:25:37 -0700 (PDT)
Message-ID: <20100715.202537.116398412.davem@davemloft.net>
References: <20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com>
	<C27F8246C663564A84BB7AB3439772421B842BD26F@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935223Ab0GPDZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:25:21 -0400
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B842BD26F@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 15 Jul 2010 07:48:40 -0700

> Stanislaw Gruszka wrote:
> 
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>> ---
>> @@ -2974,7 +2974,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct
>> bnx2_rx_ring_info *rxr, struct sk_buff *skb,
>>       int err;
>>       u16 prod = ring_idx & 0xffff;
>>
>> -     err = bnx2_alloc_rx_skb(bp, rxr, prod);
>> +     err = bnx2_alloc_rx_skb(bp, rxr, prod, GFP_KERNEL);
> 
> This should be GFP_ATOMIC since it is called from NAPI softirq
> context.

This fatal issue gives me doubts about whether this patch was even
tested at all.

Immediately the kernel memory allocator should have issued a warning
due to this GFP_KERNEL allocation in a non-sleep'able context.

Stanislaw, how did you test this patch?
