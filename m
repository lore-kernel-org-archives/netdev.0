From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: forcedeth problems on 2.6.20-rc6-mm3
Date: Mon, 05 Feb 2007 18:35:06 -0600
Message-ID: <45C7CD3A.808@shaw.ca>
References: <45C6BCE5.90103@shaw.ca>
 <Pine.LNX.4.64.0702050124320.20138@iabervon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
To: Daniel Barkalow <barkalow@iabervon.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]:15368 "EHLO
	pd5mo3so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965302AbXBFAgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 19:36:03 -0500
In-reply-to: <Pine.LNX.4.64.0702050124320.20138@iabervon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Barkalow wrote:
> On Sun, 4 Feb 2007, Robert Hancock wrote:
> 
>> Something's busted with forcedeth in 2.6.20-rc6-mm3 for me relative to
>> 2.6.20-rc6. There's no errors in dmesg, but it seems no packets ever get
>> received and so the machine can't get an IP address. I tried reverting all the
>> -mm changes to drivers/net/forcedeth.c, which didn't help. The network
>> controller shares an IRQ with the USB OHCI controller which is receiving
>> interrupts, so it doesn't seem like an interrupt routing problem, though I
>> suppose something wierd could be happening there.
> 
> IIRC, forcedeth tries to use MSI by default. Perhaps the hardware is using 
> it, but the kernel thinks enabling it didn't work? I think there's a 
> module option for forcedeth to disable MSI, which might be worth a try to 
> see if it has any effect.

I must have messed something up when testing before - reverting to 
forcedeth.c from 2.6.20-rc6 does indeed fix the problem. And it doesn't 
seem like no packets at all are received with the -mm3 version (driver 
version 0.60), either - if I do a tcpdump I can get Ethernet packets 
showing up, but I can't ping my router so it seems like something isn't 
getting through properly. With the 2.6.20-rc6 version (driver version 
0.59) it works fine. I switched back and forth between versions and this 
seems repeatable.

I don't think it's MSI related, the CK804 version of these controllers 
doesn't support MSI and the driver shouldn't be trying to use it. I 
tried the MSI and MSI-X disable options on the 0.60 driver, but that 
didn't help.

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

