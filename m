From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH v3 3/3] tg3: add support for Ethernet core in bcm4785
Date: Thu, 07 Feb 2013 15:31:55 +0100
Message-ID: <5113BADB.6090204@hauke-m.de>
References: <1360190768-390-1-git-send-email-hauke@hauke-m.de> <1360190768-390-4-git-send-email-hauke@hauke-m.de> <1360202768.796.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mcarlson@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:37699 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758635Ab3BGOcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 09:32:08 -0500
In-Reply-To: <1360202768.796.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2013 03:06 AM, Michael Chan wrote:
> On Wed, 2013-02-06 at 23:46 +0100, Hauke Mehrtens wrote: 
>> @@ -16165,7 +16256,8 @@ static int tg3_test_dma(struct tg3 *tp)
>>                         if (tg3_flag(tp, 40BIT_DMA_BUG) &&
>>                             GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
>>                                 tp->dma_rwctrl |= 0x8000;
>> -                       else if (ccval == 0x6 || ccval == 0x7)
>> +                       else if ((ccval == 0x6 || ccval == 0x7) ||
>> +                                tg3_flag(tp, ONE_DMA_AT_ONCE))
> 
> This code path is only for the older 5703 and 5704.  So it won't be
> applicable for this ethernet core, right?

I just had a look into the original source provided with my Router for
this chip and you are right, this code should be placed after the checks
for specific chips. I will resend this patch series. This
ONE_DMA_AT_ONCE does not affect my Ethernet core, because this should
only be done for rev < 2 bcm4785 chips and mine is rev 2.

>>                                 tp->dma_rwctrl |= DMA_RWCTRL_ONE_DMA;
>>  
>>                         if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703) 

Hauke
