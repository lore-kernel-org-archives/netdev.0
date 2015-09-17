From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: bcmgenet: Implement RX coalescing control
 knobs
Date: Thu, 17 Sep 2015 11:18:45 -0700
Message-ID: <55FB0405.8010503@gmail.com>
References: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com> <1442447260-14129-3-git-send-email-f.fainelli@gmail.com> <55FAFF46.7010203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33740 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbIQSW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:22:27 -0400
Received: by pacex6 with SMTP id ex6so26392476pac.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 11:22:27 -0700 (PDT)
In-Reply-To: <55FAFF46.7010203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/09/15 10:58, Florian Fainelli wrote:
> On 16/09/15 16:47, Florian Fainelli wrote:
>> Add support for the ethtool rx-frames coalescing parameter which allows
>> defining the number of RX interrupts per frames received. The RDMA
>> engine supports a configurable timeout with a resolution of
>> approximately 8.192 us.
>>
>> We can no longer enable the BDONE/PDONE interrupts as those would
>> fire for each packet/buffer received, which would defeat the MBDONE
>> interrupt purpose. The MBDONE interrupt is guaranteed to correspond to a
>> PDONE/BDONE interrupt when the threshold is set to 1.
> 
> *sigh*, I missed the initialization of the INTR_THRESHOLD register, so
> right now, we just have no interrupts configured properly for RX, will
> re-submit shortly.
> 
> Meanwhile, please send feedback if you have any, thanks!
> 

Actually, no that version of the patch is just fine, since we already
programmed the DMA_MBUF_DONE_THRESH since commit
6f5a272c99108d9f8450c454a4baede9e7cc643f (" net: bcmgenet: rework Rx
queue init")

Sorry about the noise, -ENOCOFFEE.
-- 
Florian
