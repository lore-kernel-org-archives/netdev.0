From: Chuck Ebbert <cebbert@redhat.com>
Subject: Bonding two 802.1q interfaces triggers "sleeping function called
 from invalid context"
Date: Tue, 01 May 2007 14:47:59 -0400
Message-ID: <46378B5F.9060301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031287AbXEASsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:48:02 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l41Ilxxc013315
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 14:47:59 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l41IlxqX019395
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 14:47:59 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id l41IlxmS011822
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 14:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=238307

This is kernel 2.6.20.3.

>From the bugzilla comment:

===============================================================================

I need to use a bonding through two 802.1q tag VLAN virtual interface in the
same physical network interface. When I bond interface with command :
ifenslave bond0 eth1.10 eth1.20
Console and dmesg will continues report BUG:
--------------Output1 begin kernel 2.6.20-1.2933.fc6------------
BUG: sleeping function called from invalid context at include/asm/uaccess.h:500
in_atomic():1, irqs_disabled():0
 [<c04ecadb>] copy_from_user+0x35/0x66
 [<c05c2e78>] dev_ethtool+0x51/0xa0d
 [<c05ee503>] tcp_current_mss+0x71/0xdf
 [<c05ee169>] tcp_rcv_established+0x74f/0x7de
 [<c04cf48f>] selinux_netlbl_sock_rcv_skb+0x1d/0x5b
 [<c05f3a78>] tcp_v4_do_rcv+0x1bf/0x49c
 [<c05f5f1b>] tcp_v4_rcv+0x564/0x8b1
 [<d8a3ac03>] vlan_dev_ioctl+0x7b/0xa7 [8021q]
 [<d8a3ab88>] vlan_dev_ioctl+0x0/0xa7 [8021q]
 [<d8a53102>] bond_update_speed_duplex+0x88/0xd7 [bonding]
 [<d8a5688e>] bond_mii_monitor+0x0/0x403 [bonding]
 [<d8a56c01>] bond_mii_monitor+0x373/0x403 [bonding]
 [<c061ff9d>] _spin_unlock_irq+0x5/0x7
 [<c0439e73>] hrtimer_run_queues+0x127/0x141
 [<d8a5688e>] bond_mii_monitor+0x0/0x403 [bonding]
 [<c042e673>] run_timer_softirq+0x101/0x164
 [<c042b908>] __do_softirq+0x5d/0xba
 [<c04061b1>] do_softirq+0x59/0xb1
 [<c0419df6>] smp_apic_timer_interrupt+0x76/0x80
 [<c04049b0>] apic_timer_interrupt+0x28/0x30
 [<c0402d52>] default_idle+0x0/0x3e
 [<c0402d7e>] default_idle+0x2c/0x3e
 [<c04023d0>] cpu_idle+0x9e/0xb7
 [<c074a812>] start_kernel+0x3b6/0x3be
 [<c074a25a>] unknown_bootoption+0x0/0x202
