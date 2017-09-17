From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/7] korina: performance fixes and cleanup
Date: Sun, 17 Sep 2017 13:09:21 -0700
Message-ID: <649cd233-d9b8-478b-e742-5da469df8f26@gmail.com>
References: <20170917172353.32225-1-roman@advem.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Roman Yeryomin <leroi.lists@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33310 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbdIQUJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 16:09:25 -0400
Received: by mail-io0-f196.google.com with SMTP id j26so7253153iod.0
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 13:09:25 -0700 (PDT)
In-Reply-To: <20170917172353.32225-1-roman@advem.lv>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/17/2017 10:23 AM, Roman Yeryomin wrote:
> Changes from v1:
> - use GRO instead of increasing ring size
> - use NAPI_POLL_WEIGHT instead of defining own NAPI_WEIGHT
> - optimize rx descriptor flags processing

net-next is closed at the moment, but these look like reasonable
changes, I would just replace patch 7 with a patch that entirely drops
the driver specific version since that does not serve any purpose in the
context of an in-kernel driver.

Some nice clean-ups that you should also consider for future changes:

- reduce the duplication of tests/conditions in korina_send_packet(), a
lot of them are testing for the same things and setting the same
descriptor bits

- move korina_tx() to a NAPI context instead of working from hard
interrupt context

- get rid of the MIPS dma_cache_* calls and instead properly use the
DMA-API to allocate descriptors and invalidate/write-back skb->data

> 
> Roman Yeryomin (7):
>   net: korina: don't use overflow and underflow interrupts
>   net: korina: optimize rx descriptor flags processing
>   net: korina: use NAPI_POLL_WEIGHT
>   net: korina: use GRO
>   net: korina: whitespace cleanup
>   net: korina: update authors
>   net: korina: bump version
> 
>  drivers/net/ethernet/korina.c | 230 ++++++++++++++----------------------------
>  1 file changed, 78 insertions(+), 152 deletions(-)
> 

-- 
Florian
