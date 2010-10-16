From: Lasse Makholm <lasse.makholm@gmail.com>
Subject: r8169: high CPU load (softirq) bottlenecking throughput
Date: Sat, 16 Oct 2010 23:54:58 +0200
Message-ID: <AANLkTinUL8=bkTE1dxN1OKSGJ_F4XazpgbTEVTjQ2fr=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51352 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756891Ab0JQA2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 20:28:35 -0400
Received: by bwz15 with SMTP id 15so2069051bwz.19
        for <netdev@vger.kernel.org>; Sat, 16 Oct 2010 17:28:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev people,

I'm seeing what seems to be an unreasonably high CPU utilization from
the r8169 driver on an Intel Atom board.

Serving a 1GB blob repeatedly through Apache basically maxes out one
CPU core completely...

Here is a typical snapshot of the CPU load:

11:17:23 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft
%steal  %guest   %idle
11:17:24 PM  all    0.00    0.00    6.54    0.00    0.00   17.68
0.00    0.00   75.79
11:17:24 PM    0    0.00    0.00    0.00    0.00    0.00    0.00
0.00    0.00  100.00
11:17:24 PM    1    0.00    0.00    0.00    0.00    0.00    0.00
0.00    0.00  100.00
11:17:24 PM    2    0.00    0.00   27.00    0.00    0.00   73.00
0.00    0.00    0.00
11:17:24 PM    3    0.00    0.00    0.00    0.00    0.00    0.00
0.00    0.00  100.00

There is no disk IO while this is going on (the 1GB blob is cached),
and the machine is otherwise idle.

Throughput tops out at around 50MB/s but the receiving end and the
switch is easily able to get 100MB/s from another box.

The board is a D945GCLF2D with an Atom 330 (2 x 1.6 GHz), so
presumably it should be able to pump out 100MB/s easily...

For SSH-tunneled traffic, this is a disaster because both encryption
and I/O land on the same CPU... I'm currently maxing out at 10 - 20
MB/s with SSH-tunneled traffic

The kernel is currently 2.6.36-020636rc8-generic (Ubuntu daily
snapshot) but I've tried a handful of others between here and Ubuntu's
2.6.32-24....

lspci knows the following about the NIC:

makholm@korovyov:~$ lspci -vv -s 01:00.0
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
	Subsystem: Intel Corporation Device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 40
	Region 0: I/O ports at 1000 [size=256]
	Region 2: Memory at 88100000 (64-bit, non-prefetchable) [size=4K]
	Region 4: Memory at 88000000 (64-bit, prefetchable) [size=64K]
	Expansion ROM at 88020000 [disabled] [size=128K]
	Capabilities: <access denied>
	Kernel driver in use: r8169
	Kernel modules: r8169

makholm@korovyov:~$

I have a D-Link DGE-528T (also uses the r8169 driver) that shows
similar behavior in the Atom box. Trying that cards in an Athlon II
box also show a noticable CPU load by the r8169 driver, though the
Athlon obviously copes much better...

Any tips on how to improve the situation? I'd be happy to provide more
info and/or test some patches etc. if needed...

Thanks
/Lasse
