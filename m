From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: GRO with non napi driver: BUG in __napi_complete
Date: Tue, 17 Mar 2009 09:35:21 +0100
Message-ID: <49BF60C9.1080100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:56551 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbZCQIfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 04:35:22 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2H8ZKCd478080
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 08:35:20 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2H8ZJ1Q3756282
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 09:35:20 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2H8ZJj7009348
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 09:35:19 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I try to activate GRO on a non napi driver (2.6.29-rc8). Running an iperf test
causes a bug in __napi_complete.

kernel BUG at net/core/dev.c:2625!
illegal operation: 0001 <DD>#1<A8> PREEMPT SMP
Modules linked in:
CPU: 1 Not tainted 2.6.29-rc8-00124-g5bee17f #8
Process swapper (pid: 0, task: 000000002ff7ccc0, ksp: 000000002ff97d48)
Krnl PSW : 0404d00180000000 00000000002d1f4e (__napi_complete+0x82/0x88)
           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
...
<DD>  261.377396<A8> Call Trace:
<DD>  261.377400<A8> (<DD><00000000002cb752><A8> process_backlog+0xba/0x104)
<DD>  261.377410<A8>  <DD><00000000002cb5ba><A8> net_rx_action+0x102/0x1e0
<DD>  261.377418<A8>  <DD><000000000004921e><A8> __do_softirq+0x92/0x168
<DD>  261.377428<A8>  <DD><0000000000020936><A8> do_softirq+0x96/0xb0
<DD>  261.377436<A8>  <DD><00000000000493c0><A8> irq_exit+0x70/0x80
<DD>  261.377444<A8>  <DD><000000000025789c><A8> do_IRQ+0x174/0x194
<DD>  261.377455<A8>  <DD><00000000000258da><A8> io_return+0x0/0x8
<DD>  261.377464<A8>  <DD><00000000000246fe><A8> vtime_stop_cpu+0xb2/0xc0
<DD>  261.377473<A8> (<DD><00000007005b1007><A8> 0x7005b1007)

What is the intention process_backlog calls __napi_complete() instead of
napi_complete(), this looks suspicious to me. Can anybody help?

Thanks,

Frank

