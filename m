From: punnaiah choudary kalluri <punnaia@xilinx.com>
Subject: Kernel BUG while sending data on 10mbps halfduplex link
Date: Thu, 3 Jul 2014 09:07:52 +0530
Message-ID: <CAGnW=BZb_DHb7JHc0h_4mWH0q8K9mONnwW554jwnsaxFAW25WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:60817 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754629AbaGCDhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 23:37:54 -0400
Received: by mail-lb0-f170.google.com with SMTP id 10so8784764lbg.29
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 20:37:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  While sending the data traffic on zynq development board using 10 mbps
 half-duplex link, observed the kernel BUG in skbuff handling.

Zynq setup:
ifconfig eth0 192.186.1.2

Host machine setup:
ifconfig eth0 192.186.1.3
ethtool -s eth0 speed 10 duplex half
tcpreplay -i eth0 kernelpaniccapturejune24.pcap

 Any pointers/directions for finding the root cause for this issue ?

root@zynq:~# [  128.841470] random: nonblocking pool is initialized
[  141.726352] skbuff: skb_over_panic: text:c031b890 len:16383
put:16383 head:eea80000 data:eea80040 tail:0xeea8403f end:0xeea80640
dev:eth0
[  141.726354] ------------[ cut here ]------------
[  141.726354] kernel BUG at net/core/skbuff.c:126!
[  141.726355] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[  141.726356] Modules linked in: ipv6
[  141.726357] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-xilinx #1
[  141.726358] task: c06af670 ti: c06a4000 task.ti: c06a4000
[  141.726358] PC is at skb_panic+0x50/0x5c
[  141.726359] LR is at skb_panic+0x50/0x5c
[  141.726360] pc : [<c0494d68>]    lr : [<c0494d68>]    psr: 60070113
[  141.726360] sp : c06a5de8  ip : c07b8da8  fp : 2ea80040
[  141.726362] r10: ef10b810  r9 : c06af344  r8 : 00000000
[  141.726362] r7 : c05d39c4  r6 : eea80000  r5 : eea80040  r4 : eea8403f
[  141.726364] r3 : c06af670  r2 : 00000000  r1 : 60070113  r0 : 0000007d
[  141.726365] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
Segment kernel
[  141.726366] Control: 18c5387d  Table: 2e9c404a  DAC: 00000015
[  141.726367] Process swapper/0 (pid: 0, stack limit = 0xc06a4240)
[  141.726368] Stack: (0xc06a5de8 to 0xc06a6000)

Regards,
Punnaiah
