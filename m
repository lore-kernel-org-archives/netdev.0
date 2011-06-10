From: Daniel Hellstrom <daniel@gaisler.com>
Subject: Re: CRC endianess problem on DGE-510T
Date: Fri, 10 Jun 2011 15:12:49 +0200
Message-ID: <4DF21851.7060206@gaisler.com>
References: <4DF1CFC2.5080101@gaisler.com> <1307709301.22348.594.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:45924 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757212Ab1FJNND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 09:13:03 -0400
In-Reply-To: <1307709301.22348.594.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:

>On Fri, 2011-06-10 at 10:03 +0200, Daniel Hellstrom wrote:
>  
>
>>Hello,
>>
>>I'm having problems with the PCI network board D-LINK DGE-510T on 
>>SPARC32/LEON. The CRC calculated by ether_crc_le() does not match the 
>>CRC, however after swapping the result it matches. This is the same 
>>behaviour with the 3 boards I have. After applying the patch below 
>>everything works.
>>
>>Does anyone know if this is a correct patch or has had similar problems 
>>on big endian machines?
>>    
>>
>
>No idea about this hardware, but it looks reasonable - the contents of
>the EEPROM are treated as being in little-endian order, except when
>reading the CRC for comparison.
>  
>
Ok, then I will submit my patch to the list.

The funny thing is that other vendors than DLINK doesn't check the CRC, 
they might have tested it on a big endian machine... but it might just 
be a coincidence.

Thanks,
Daniel

>  
>
>>Daniel
>>
>>
>>
>>
>>From: Daniel Hellstrom <daniel@gaisler.com>
>>Date: Wed, 6 Apr 2011 15:01:44 +0200
>>[PATCH] dl2k: EEPROM CRC calculation wrong endianess on bigendian machine
>>
>>Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
>>---
>> drivers/net/dl2k.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>>diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
>>index c445457..4bbbd7b 100644
>>--- a/drivers/net/dl2k.c
>>+++ b/drivers/net/dl2k.c
>>@@ -346,7 +346,7 @@ parse_eeprom (struct net_device *dev)
>>        if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {  /* D-Link Only */
>>                /* Check CRC */
>>                crc = ~ether_crc_le (256 - 4, sromdata);
>>-               if (psrom->crc != crc) {
>>+               if (psrom->crc != cpu_to_le32(crc)) {q
>>    
>>
>
>q?
>
>Ben.
>
>  
>
>>                        printk (KERN_ERR "%s: EEPROM data CRC error.\n",
>>                                        dev->name);
>>                        return -1;
>>--
>>1.5.4
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>    
>>
>
>  
>

