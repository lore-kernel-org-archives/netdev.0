From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] bnx2x: Insane RX rings
Date: Thu, 09 Sep 2010 22:45:05 +0200
Message-ID: <1284065105.4782.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63371 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab0IIUpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 16:45:19 -0400
Received: by fxm16 with SMTP id 16so1255844fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 13:45:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I have a small dev machine, 4GB of ram,
a dual E5540 cpu (quad core, 2 threads per core), 
so a total of 16 threads.

Two ethernet ports, eth0 and eth1, 

02:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57711E 10Gigabit PCIe
02:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57711E 10Gigabit PCIe

bnx2x 0000:02:00.0: eth0: using MSI-X  IRQs: sp 68  fp[0] 69 ... fp[15] 84
bnx2x 0000:02:00.1: eth1: using MSI-X  IRQs: sp 85  fp[0] 86 ... fp[15] 101


Default configuration :

ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:		4078
RX Mini:	0
RX Jumbo:	0
TX:		4078
Current hardware settings:
RX:		4078
RX Mini:	0
RX Jumbo:	0
TX:		4078

Problem is : With 16 RX queues per device , thats 4078*16*2Kbytes per
ethernet port.

Total : 

skbuff_head_cache 130747 131025    256   15    1 : tunables  120   60    8 : slabdata   8735   8735     40
size-2048         130866 130888   2048    2    1 : tunables   24   12    8 : slabdata  65444  65444     28

Thats about 300 Mbytes of memory, just in case some network trafic will occur.

Lets do something about that ?

Thanks


