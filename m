From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: [PATCH 1/2] bnx2: allocate with GFP_KERNEL flag on RX path init
Date: Thu, 15 Jul 2010 22:57:08 -0700
Message-ID: <F7629DFD-ACD4-473D-95DC-414294A6DEDB@earthlink.net>
References: <20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com> <C27F8246C663564A84BB7AB3439772421B842BD26F@IRVEXCHCCR01.corp.ad.broadcom.com> <20100715.202537.116398412.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, sgruszka@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:43081 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753529Ab0GPF5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 01:57:22 -0400
In-Reply-To: <20100715.202537.116398412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 15, 2010, at 8:25 PM, David Miller wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 15 Jul 2010 07:48:40 -0700
> 
>> Stanislaw Gruszka wrote:
>> 
>>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>>> ---
>>> @@ -2974,7 +2974,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct
>>> bnx2_rx_ring_info *rxr, struct sk_buff *skb,
>>>      int err;
>>>      u16 prod = ring_idx & 0xffff;
>>> 
>>> -     err = bnx2_alloc_rx_skb(bp, rxr, prod);
>>> +     err = bnx2_alloc_rx_skb(bp, rxr, prod, GFP_KERNEL);
>> 
>> This should be GFP_ATOMIC since it is called from NAPI softirq
>> context.
> 
> This fatal issue gives me doubts about whether this patch was even
> tested at all.
> 
> Immediately the kernel memory allocator should have issued a warning
> due to this GFP_KERNEL allocation in a non-sleep'able context.
> 
> Stanislaw, how did you test this patch?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Group,

		Why NOT GFP_NOWAIT. This won't use the last resource pages
		versus GFP_ATOMIC?

		GFP_ATOMIC IMO, SHOULD be used in the paths that cleans
		and frees pages.

Mitchell Erblich


