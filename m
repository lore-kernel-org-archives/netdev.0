From: Ben Greear <greearb@candelatech.com>
Subject: r8169 crash (probably my fault) in 3.3.0-rc1+ (net-next)
Date: Thu, 09 Feb 2012 14:20:27 -0800
Message-ID: <4F3446AB.2080209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34585 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758605Ab2BIWU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 17:20:28 -0500
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q19MKRVf012292
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 9 Feb 2012 14:20:27 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am hacking on the 8169 code, (adding RX-ALL and RX-FCS support on top of
my previously posted patches) so this could easily be my
fault..but just in case someone else has seen it, please
let me know....


BUG: unable to handle kernel NULL pointer dereference at 00000c9c
IP: [<c07083f6>] skb_gro_reset_offset+0x3a/0x73
*pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in: bridge 8021q garp stp llc ip_gre gre veth fuse macvlan pktgen coretemp hwmon nfs lockd]

Pid: 7659, comm: tshark Not tainted 3.3.0-rc1+ #25 To Be Filled By O.E.M. To Be Filled By O.E.M./To be fi.
EIP: 0060:[<c07083f6>] EFLAGS: 00210246 CPU: 0
EIP is at skb_gro_reset_offset+0x3a/0x73
EAX: 00000c9c EBX: f16353c0 ECX: f175d030 EDX: f16353c0
ESI: f16353d8 EDI: f4e47c68 EBP: f580bf48 ESP: f580bf3c
  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process tshark (pid: 7659, ti=f580a000 task=f14ede60 task.ti=f1444000)
Stack:
  f16353c0 f4d184cc f4e47c40 f580bf58 c070c1ad f4d18000 00000002 f580bfb0
  f88fff68 f4d18bb4 3148c000 00000003 f5959060 00000040 0003dc40 f4d18b88
  00000040 803fbf8c f4d18000 f4d184c0 00000003 f4d184cc 00000000 f16353c0
Call Trace:
  [<c070c1ad>] napi_gro_receive+0x10/0x24
  [<f88fff68>] rtl8169_poll+0x2d6/0x443 [r8169]
  [<c070c2ba>] net_rx_action+0x92/0x1a2
  [<c042ad54>] __do_softirq+0x6d/0xfa
  [<c042ace7>] ? irq_enter+0x4d/0x4d
  <IRQ>
  [<c042aba4>] ? irq_exit+0x32/0x93
  [<c0403a20>] ? do_IRQ+0x7c/0x90
  [<c07a96e9>] ? common_interrupt+0x29/0x30


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
