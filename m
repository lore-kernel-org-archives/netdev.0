From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: ax88796 driver
Date: Wed, 23 Apr 2014 14:05:13 +0100
Message-ID: <5357BA89.4070503@codethink.co.uk>
References: <534F1550.50704@mail.ru> <1398131999.3624.167.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	Alexander Varnin <fenixk19@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:48297 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752185AbaDWNF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 09:05:27 -0400
In-Reply-To: <1398131999.3624.167.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/04/14 02:59, Ben Hutchings wrote:
> On Thu, 2014-04-17 at 03:42 +0400, Alexander Varnin wrote:
>> Hello!
>>
>> I am currently working on kernel and dealing with ax88796 driver, that
>> has been written by Ben Dooks <ben@simtec.co.uk>. Since his address is
>> not available anymore (says "Ben doesn't work here any more"), I want
>> to ask help from somebody, who maybe somehow related to this driver.
>
> I'm cc'ing Ben, but I doubt he'll want to remember this driver.
>
> Ben.

Hi, I really do not remember this driver as we only used this device
on a couple of projects before changing to another supplier.

>> I want to ask on source code, because there is some non-obvious lines.
>>
>> Take a look on ax_initial_check function from ax88796.c please [1].
>>
>> Here is lines 127-129 of it:
>>
>> ei_outb (E8390_NODMA + E8390_PAGE1 + E8390_STOP, ioaddr + E8390_CMD);
>> regd = ei_inb (ioaddr + 0x0d);
>> ei_outb (0xff, ioaddr + 0x0d);
>>
>> This is supposed to be read and write to 0xD register on PAGE 1 of
>> AX88796. But that offset stands for "Multicast Address Register 5
>> ( MAR5 )" in AX88796 datasheet [2].
>>
>> What is the point of doing so? That looks very like a mistake. If it
>> is a mistake, I could make and send patch to fix it. But, please,
>> explain why is it done?
>>
>>
>> [1] http://lxr.free-electrons.com/source/drivers/net/ethernet/8390/ax88796.c#L116
>> [2] http://www.digchip.com/datasheets/parts/datasheet/562/AX88796-pdf.php

Hmm, is there an actual bug here or is this something that
we think is wrong? I could have a look but I do not have any
bootable test hardware available.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
