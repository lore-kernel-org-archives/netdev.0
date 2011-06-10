From: Daniel Hellstrom <daniel@gaisler.com>
Subject: Re: [PATCH 1/1] dl2k: EEPROM CRC calculation wrong endianess on bigendian
 machine
Date: Fri, 10 Jun 2011 16:54:54 +0200
Message-ID: <4DF2303E.8000202@gaisler.com>
References: <1307711777-12119-1-git-send-email-daniel@gaisler.com> <1307713751.22348.602.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail202c2.megamailservers.com ([69.49.111.103]:54722 "EHLO
	mail202c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421Ab1FJOzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 10:55:08 -0400
In-Reply-To: <1307713751.22348.602.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:

>On Fri, 2011-06-10 at 15:16 +0200, Daniel Hellstrom wrote:
>  
>
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
>> 	if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {	/* D-Link Only */
>> 		/* Check CRC */
>> 		crc = ~ether_crc_le (256 - 4, sromdata);
>>-		if (psrom->crc != crc) {
>>+		if (psrom->crc != cpu_to_le32(crc)) {q
>>    
>>
>
>You still have a rogue 'q' there.
>  
>
ooh, you got a sharp eye, I wonder how that made it into there... I will 
resend, thanks!

Daniel

>Ben.
>
>  
>
>> 			printk (KERN_ERR "%s: EEPROM data CRC error.\n",
>> 					dev->name);
>> 			return -1;
>>    
>>
>
>  
>

