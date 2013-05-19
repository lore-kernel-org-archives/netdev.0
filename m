From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] 3c59x: fix PCI resource management
Date: Sun, 19 May 2013 23:36:09 +0400
Message-ID: <519929A9.7060509@cogentembedded.com>
References: <201305020240.34487.sergei.shtylyov@cogentembedded.com> <20130506.122040.1138770239806939990.davem@davemloft.net> <5187E884.7060101@cogentembedded.com> <20130506.135305.1659397370290340459.davem@davemloft.net> <5187F512.4070104@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:45488 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab3ESTgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 15:36:12 -0400
Received: by mail-lb0-f178.google.com with SMTP id w10so4396064lbi.37
        for <netdev@vger.kernel.org>; Sun, 19 May 2013 12:36:11 -0700 (PDT)
In-Reply-To: <5187F512.4070104@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/06/2013 10:23 PM, Sergei Shtylyov wrote:

>
>>>>> @@ -1215,12 +1217,13 @@ static int vortex_probe1(struct device *
>>>>>        vp->mii.reg_num_mask = 0x1f;
>>>>>
>>>>>        /* Makes sure rings are at least 16 byte aligned. */
>>>>> -    vp->rx_ring = pci_alloc_consistent(pdev, sizeof(struct 
>>>>> boom_rx_desc) *
>>>>> -    RX_RING_SIZE
>>>>> -                       + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>>>>> -                       &vp->rx_ring_dma);
>>>>> +    vp->rx_ring = pci_alloc_consistent(pdev,
>>>>> + sizeof(struct boom_rx_desc) * RX_RING_SIZE +
>>>>> + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>>>>> +                &vp->rx_ring_dma);
>
>>>> This code was properly indented before your changes, but it isn't
>>>> afterwards.
>
>>>     David, that's not my change, it's was Andrew Morton who changed 
>>> that
>>>     (in order not to cross 80 columns).
>
>> Ok, whoever submits this next needs to undo that.
>
>     How about I completely drop this change (and maybe deal with it in 
> a subsequent cleanup patch)?

    It appears I had fixes for only a small part of 
scripts/checkpatch.pl complaints
in this driver:

total: 114 errors, 428 warnings, 3327 lines checked

NOTE: whitespace errors detected, you may wish to use scripts/cleanpatch or
       scripts/cleanfile

    I guess you don't need me to clean up the coding style in such an 
old driver,
and I don't want to spend time on it either. So I'm going to let the lot 
of overly
long lines in the driver live forever. :-)

WBR, Sergei
