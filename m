From: Andrew Theurer <habanero@us.ibm.com>
Subject: eHEA driver issues from net-2.6.24
Date: Wed, 22 Aug 2007 16:55:03 -0500
Message-ID: <46CCB0B7.3030302@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36820 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934233AbXHVVzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 17:55:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MLt5hu028872
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 17:55:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MLt5tl496836
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 17:55:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MLt4Sh013070
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 17:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In testing the new NAPI improvements on ehea, I get the following:

kernel BUG at include/linux/netdevice.h:318!
cpu 0x1: Vector: 700 (Program Check) at [c00000000f613ac0]
    pc: d000000000091054: .ehea_poll+0x1e8/0x1334 [ehea]
    lr: c0000000003fe394: .net_rx_action+0x1b8/0x254
    sp: c00000000f613d40
   msr: 8000000000029032
  current = 0xc0000005aff9e8b0
  paca    = 0xc0000000006e1300
    pid   = 0, comm = swapper
kernel BUG at include/linux/netdevice.h:318!
enter ? for help
[c00000000f613e40] c0000000003fe394 .net_rx_action+0x1b8/0x254
[c00000000f613ef0] c000000000057b70 .__do_softirq+0xa8/0x164
[c00000000f613f90] c000000000024438 .call_do_softirq+0x14/0x24
[c000000b8ffbf9f0] c00000000000bd30 .do_softirq+0x68/0xac
[c000000b8ffbfa80] c000000000057cc4 .irq_exit+0x54/0x6c
[c000000b8ffbfb00] c00000000000c358 .do_IRQ+0x170/0x1ac
[c000000b8ffbfb90] c000000000004780 hardware_interrupt_entry+0x18/0x98
--- Exception: 501 (Hardware Interrupt) at c000000000010bdc 
.cpu_idle+0x114/0x1e0
[c000000b8ffbfe80] c000000000010bd0 .cpu_idle+0x108/0x1e0 (unreliable)
[c000000b8ffbff00] c000000000026db0 .start_secondary+0x160/0x184
[c000000b8ffbff90] c000000000008364 .start_secondary_prolog+0xc/0x10


I'm a little confused if the port_napi_enable() is being called when the 
device is initialized, but then again, this is all new to me (should it 
be called in ehea_open?).  I see it called on some reset routines, but 
not on the first initialization.


Also, on this code, in ehea_sense_port_attr()

/* Number of default QPs */
        if (use_mcs)
                port->num_def_qps = cb0->num_default_qps;
        else
                port->num_def_qps = 1;
               

When using napi, since we have multi-queue napi support now, wouldn't we 
want to use all the default qps instead of 1?

Thanks,

-Andrew




 
