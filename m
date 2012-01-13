From: Michael Mueller <malware@t-online.de>
Subject: Re: [PATCH] Making de2104x working with BNC connection on 21040 chipset
Date: Fri, 13 Jan 2012 22:30:47 +0100
Message-ID: <4F10A287.2070008@t-online.de>
References: <4F0F641B.5090407@t-online.de> <CAP=VYLpWbcBae11fcQPcuPmdfvir7N6F9QMdzXip=i4mMHjxsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout09.t-online.de ([194.25.134.84]:41348 "EHLO
	mailout09.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759230Ab2AMVbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 16:31:00 -0500
In-Reply-To: <CAP=VYLpWbcBae11fcQPcuPmdfvir7N6F9QMdzXip=i4mMHjxsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

you wrote [copy to you]:
>> while I recently updated an older machine to the latest Debian
>> distribution which included updating the kernel from 2.4.x to 3.0 the
>> tulip driver did stop working for my network card. The replacement
>> driver de2104x did initialize the network interfaces but no transmission
>> was possible.
> 
> Did you try the original de4x5.c driver?   I believe it was all that existed
> back in the 2.4 vintage, and I think it was kept around just to keep old
> cards that didn't like the "new" tulip driver working.

In 2.4.x the tulip driver was present and did work for me when selecting
the transceiver by module parameter.

The original de4x5 does not exist in 3.0. The comments at the top of
de2104x.c suggest it had been consolidated into this one. The de2104x
driver is the one autoloaded due to the PCI id of the device, see bottom
for lspci output. So it seems to be the obvious candidate to get
running. Selecting the transceiver using ethtool might to be sufficient
for this corner case. Otherwise the media auto dectection sheme would
have to be changed too which may cause trouble to users of the currently
about exclusively used twisted pair cabling. The way I solved the
problem I see no harm taken.

When trying the de4x5 using 2.6.32 - which is what I can boot into
without too much problems - it did lock the machine while starting the
interface (ifconfig up). Sorry, but I do not feel like digging into this
just now.

A comment in the de4x5 driver source suggest that for the 21040 chipset
it is a choice of the board maker to connect a BNC, an AUI port or both
selectable by jumper. Mine has no AUI, probably because two of them
would not fit onto the slot plate together with 2 TP ports while there
is enough space for 2 TP and 2 BNC.


Michael


00:11.0 0604: 1011:0001 (rev 02) (prog-if 00 [Normal decode])
        Flags: bus master, medium devsel, latency 64
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=64
        I/O behind bridge: 00009000-00009fff
        Memory behind bridge: cfe00000-cfefffff
        Prefetchable memory behind bridge: cdb00000-cdbfffff

[AGP left out]

02:04.0 0200: 1011:0002 (rev 23)
        Flags: bus master, medium devsel, latency 64, IRQ 11
        I/O ports at 9c00 [size=128]
        Memory at cfefff80 (32-bit, non-prefetchable) [size=128]
        Kernel driver in use: de2104x

02:05.0 0200: 1011:0002 (rev 23)
        Flags: bus master, medium devsel, latency 64, IRQ 11
        I/O ports at 9800 [size=128]
        Memory at cfefff00 (32-bit, non-prefetchable) [size=128]
        Kernel driver in use: de2104x
