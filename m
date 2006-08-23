From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] b44: fix eeprom endianess issue
Date: Wed, 23 Aug 2006 12:55:02 -0400
Message-ID: <44EC8866.9050704@garzik.org>
References: <200608231232.05750.mb@bu3sch.de> <200608231238.49783.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, zambrano@broadcom.com,
	netdev@vger.kernel.org, davem@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51405 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750704AbWHWQzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 12:55:08 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608231238.49783.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
>> Please note that this test is only compile tested, as
>> I don't have a b44 device.

>> @@ -2055,7 +2055,7 @@
>>  	u16 *ptr = (u16 *) data;
>>  
>>  	for (i = 0; i < 128; i += 2)
>> -		ptr[i / 2] = readw(bp->regs + 4096 + i);
>> +		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
>>  


This looks a bit weird.  readw() swaps on big-endian already.

This patch swaps each word -again- on big-endian, even though the only 
user of the eeprom data is the get-invariants code that reads the MAC 
address and phy id.

	Jeff


