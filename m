From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 13:49:48 -0500
Message-ID: <07a78491-3523-99fd-f08c-10ce277a1793@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
        nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pb-sasl2.pobox.com ([64.147.108.67]:63357 "EHLO
        sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934873AbcKXStv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 13:49:51 -0500
In-Reply-To: <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-24 01:34 PM, Mark Lord wrote:
>From tracing through the powerpc arch code, this is the buffer that
> is being directly DMA'd into.  And the USB layer does an invalidate_dcache
> on that entire buffer before initiating the DMA (confirmed via printk).

Slight correction:  the invalidate_dcache_range() is only done when
using kmalloc'd buffers.  I have converted the driver here
to use usb_alloc_coherent() instead, so that now gets skipped
since the memory is never cached.
