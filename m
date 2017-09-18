From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [PATCH net-next v2 0/7] korina: performance fixes and cleanup
Date: Mon, 18 Sep 2017 16:02:43 +0300
Message-ID: <CACiydb+Au=X4wvw_ToLOw-g=y504kby4y5NwG9czFE8Hs8vnoQ@mail.gmail.com>
References: <20170917172353.32225-1-roman@advem.lv> <649cd233-d9b8-478b-e742-5da469df8f26@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36769 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdIRNCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 09:02:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id r136so825815wmf.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 06:02:45 -0700 (PDT)
In-Reply-To: <649cd233-d9b8-478b-e742-5da469df8f26@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 September 2017 at 23:09, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
>
> On 09/17/2017 10:23 AM, Roman Yeryomin wrote:
>> Changes from v1:
>> - use GRO instead of increasing ring size
>> - use NAPI_POLL_WEIGHT instead of defining own NAPI_WEIGHT
>> - optimize rx descriptor flags processing
>
> net-next is closed at the moment, but these look like reasonable
> changes, I would just replace patch 7 with a patch that entirely drops
> the driver specific version since that does not serve any purpose in the
> context of an in-kernel driver.

OK

> Some nice clean-ups that you should also consider for future changes:
>
> - reduce the duplication of tests/conditions in korina_send_packet(), a
> lot of them are testing for the same things and setting the same
> descriptor bits

Already doing that :)

> - move korina_tx() to a NAPI context instead of working from hard
> interrupt context
>
> - get rid of the MIPS dma_cache_* calls and instead properly use the
> DMA-API to allocate descriptors and invalidate/write-back skb->data

OK

>>
>> Roman Yeryomin (7):
>>   net: korina: don't use overflow and underflow interrupts
>>   net: korina: optimize rx descriptor flags processing
>>   net: korina: use NAPI_POLL_WEIGHT
>>   net: korina: use GRO
>>   net: korina: whitespace cleanup
>>   net: korina: update authors
>>   net: korina: bump version
>>
>>  drivers/net/ethernet/korina.c | 230 ++++++++++++++----------------------------
>>  1 file changed, 78 insertions(+), 152 deletions(-)
>>
>
> --
> Florian
