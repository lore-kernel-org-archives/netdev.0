From: steven <mqyoung@gmail.com>
Subject: Issue on RTL8169scd(l), can not transmit packet
Date: Thu, 20 May 2010 16:21:50 +0800
Message-ID: <1274343710.30646.104.camel@steven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:62363 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab0ETI12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 04:27:28 -0400
Received: by pwi5 with SMTP id 5so1975873pwi.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 01:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

I am porting openPOWERLINK to Loongson/MIPS platform, so I have to write
a driver for RTL8169scl(RTL8169scd in kernel) firstly.

Now, my driver could receive packet(confirmed by printing the content of
packets and comparing them with the data wireshark captured). 

But RTL8169 didn't send any packet(I use wireshark to capture the
packet). And I found some bits in Tx Desc(Transmit Descriptor) has been
modified, such as OWN, that's to say RTL8169 could read/write the
transmit descriptor buffer. Things seems OK, but I can not capture any
packet.()
  I use pci_alloc_consistent to allocate the memory for TxDesc/RxDesc Tx
buffer/Rx buffer. The first field of my TxDesc is 0xb000003c.
  The environment:
                 Target<===> HUB <===>PC_with_wireshark

The LED(whose port connects to the target) on HUB doesn't flash when the
target keeps sending packet or it receives packets.

I print the content of all the registers of RTL8169 in Linux kernel, I
found the configuration in kernel and in my driver are the
same except PHY Access, but the config of all the PHY regs are the same
with kernel's. There is no "system error interrupt" occurs, but I am not
sure whether it will screw up. 

[14403.742503] 0x10---------0x9EAD4000
[14403.742991] 0x14---------0x00000000
[14403.743478] 0x18---------0x00000000
[14403.744799] 0x1C---------0x00000000
[14403.745309] 0x20---------0x9EB18000
[14403.745801] 0x24---------0x00000000
[14403.746289] 0x28---------0x05744700
[14403.746778] 0x2C---------0xB61C07FB
[14403.747265] 0x37---------0x0C
[14403.747702] 0x38---------0x00
[14403.749221] 0x3C---------0xC1FF
[14403.749692] 0x3E---------0x0000
[14403.750146] 0x40---------0x1B000600
[14403.750636] 0x44---------0x00000000
[14403.751123] 0x48---------0x09AF2BDA
[14403.751612] 0x50---------0x00
[14403.752973] 0x51---------0x05
[14403.753423] 0x52---------0xCD
[14403.753860] 0x53---------0x00
[14403.754295] 0x54---------0xA1
[14403.754731] 0x55---------0x00
[14403.755164] 0x56---------0x01
[14403.755600] 0x58---------0x00000000
[14403.757212] 0x60---------0x00000000
[14403.757722] 0x6c---------0x06
[14403.758160] 0xC4---------0x8EAD
[14403.758771] 0xC6---------0x7962
[14403.759230] 0xC8---------0x1020
[14403.759682] 0xCA---------0x45D6
[14403.761115] 0xCC---------0x6353
[14403.761589] 0xDA---------0x4000
[14403.762047] 0xE0---------0x0028
[14403.762500] 0xE4---------0x9E76C000
[14403.762987] 0xE8---------0x00000000
[14403.763475] 0xEC---------0x0000003F

Does anyone have some idea? Thank you very very much.

Steven

