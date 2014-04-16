From: Alexander Varnin <fenixk19@mail.ru>
Subject: ax88796 driver
Date: Thu, 17 Apr 2014 03:42:08 +0400
Message-ID: <534F1550.50704@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.176.58]:41115 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757038AbaDPXm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 19:42:29 -0400
Received: from smtp20.mail.ru (smtp20.mail.ru [94.100.176.173])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id 669DF112FA4FE
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 03:42:26 +0400 (MSK)
Received: from [37.204.187.134] (port=46779 helo=[192.168.1.108])
	by smtp20.mail.ru with esmtpa (envelope-from <fenixk19@mail.ru>)
	id 1WaZSz-00086p-ME
	for netdev@vger.kernel.org; Thu, 17 Apr 2014 03:42:09 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I am currently working on kernel and dealing with ax88796 driver, that has been written by Ben Dooks <ben@simtec.co.uk>. Since his address is not available anymore (says "Ben doesn't work here any more"), I want to ask help from somebody, who maybe somehow related to this driver.

I want to ask on source code, because there is some non-obvious lines.

Take a look on ax_initial_check function from ax88796.c please [1].

Here is lines 127-129 of it:

ei_outb (E8390_NODMA + E8390_PAGE1 + E8390_STOP, ioaddr + E8390_CMD);
regd = ei_inb (ioaddr + 0x0d);
ei_outb (0xff, ioaddr + 0x0d);

This is supposed to be read and write to 0xD register on PAGE 1 of AX88796. But that offset stands for "Multicast Address Register 5 ( MAR5 )" in AX88796 datasheet [2].

What is the point of doing so? That looks very like a mistake. If it is a mistake, I could make and send patch to fix it. But, please, explain why is it done?


[1] http://lxr.free-electrons.com/source/drivers/net/ethernet/8390/ax88796.c#L116
[2] http://www.digchip.com/datasheets/parts/datasheet/562/AX88796-pdf.php

--

Alexander.
