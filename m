From: Sachin Sant <sachinp@in.ibm.com>
Subject: [2.6.30-git21] Network Namespace test failure
Date: Wed, 24 Jun 2009 19:20:22 +0530
Message-ID: <4A422F1E.3050208@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: serue@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	matthltc@us.ibm.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:53904 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbZFXNuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 09:50:35 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n5ODoSlY006643
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 23:50:28 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5ODoavX565376
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 23:50:36 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5ODoaDI016736
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 23:50:36 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While executing Newtork namespace tests from LTP[1] May release,
the machine crashed with following o/p. This is a PowerPC
blade(Power 6)

cpu 0x1: Vector: 300 (Data Access) at [c00000000fff7310]
    pc: d0000000021c09dc: .veth_xmit+0x90/0x26c [veth]
    lr: d0000000021c09ac: .veth_xmit+0x60/0x26c [veth]
    sp: c00000000fff7590
   msr: 8000000000009032
   dar: 7
 dsisr: 40000000
  current = 0xc00000004045bc80
  paca    = 0xc000000000ff2600
    pid   = 0, comm = swapper
enter ? for help
[c00000000fff7640] c00000000051b2b4 .dev_hard_start_xmit+0x2c4/0x3d8
[c00000000fff7710] c000000000539288 .__qdisc_run+0x184/0x330
[c00000000fff7800] c00000000051b894 .dev_queue_xmit+0x31c/0x4d4
[c00000000fff78a0] c0000000005249e8 .neigh_resolve_output+0x394/0x408
[c00000000fff7970] d0000000020c3168 .ip6_output_finish+0xd8/0x16c [ipv6]
[c00000000fff7a20] d0000000020c5f60 .ip6_output2+0x2b8/0x2e0 [ipv6]
[c00000000fff7ac0] d0000000020c6d60 .ip6_output+0xdd8/0xe38 [ipv6]
[c00000000fff7bd0] d0000000020e8af4 .mld_sendpack+0x388/0x590 [ipv6]
[c00000000fff7ce0] d0000000020e9f24 .mld_ifc_timer_expire+0x300/0x378 [ipv6]
[c00000000fff7db0] c0000000000abca0 .run_timer_softirq+0x200/0x2e0
[c00000000fff7eb0] c0000000000a47e4 .__do_softirq+0x15c/0x298
[c00000000fff7f90] c000000000030bb4 .call_do_softirq+0x14/0x24
[c00000007e4338f0] c00000000000e5d8 .do_softirq+0x98/0xe4
[c00000007e433990] c0000000000a4460 .irq_exit+0x64/0xc4
[c00000007e433a10] c00000000002d278 .timer_interrupt+0xe4/0x114
[c00000007e433aa0] c000000000003718 decrementer_common+0x118/0x180
--- Exception: 901 (Decrementer) at c00000000000e528
.raw_local_irq_restore+0x74/0x8c
[c00000007e433e20] c0000000000144e8 .cpu_idle+0x118/0x1bc
[c00000007e433ec0] c0000000005cff14 .start_secondary+0x384/0x3c8
[c00000007e433f90] c0000000000082d4 .start_secondary_prolog+0x10/0x14
1:mon> r
R00 = 0000000000001003   R16 = c000000000f91200
R01 = c00000000fff7590   R17 = 0000000000000000
R02 = d0000000021cace8   R18 = ffffffffffffffff
R03 = c00000003f4e5780   R19 = 0000000000000000
R04 = c00000003eb84a80   R20 = c00000003d2bd39c
R05 = c00000003d438580   R21 = c00000000fff4080
R06 = c0000000374a35c4   R22 = 0000000100009dea
R07 = c000000037336f80   R23 = d0000000021c25f0
R08 = 0000000000000000   R24 = c00000003d438580
R09 = 3fffffffc8e93a7f   R25 = c00000003eb88a80
R10 = ffffffffffffffff   R26 = c00000003eb85080
R11 = 0000000000000008   R27 = c00000003ecd3780
R12 = d0000000020ffa30   R28 = c00000003d438580
R13 = c000000000ff2600   R29 = c00000003ecd3780
R14 = 0000000000000000   R30 = c000000000e97a40
R15 = 000000000767e1e8   R31 = c00000000fff7590
pc  = d0000000021c09dc .veth_xmit+0x90/0x26c [veth]
lr  = d0000000021c09ac .veth_xmit+0x60/0x26c [veth]
msr = 8000000000009032   cr  = 24000044
ctr = c000000000506dc0   xer = 0000000020000001   trap =  300
dar = 0000000000000007   dsisr = 40000000
1:mon> 
1:mon> di $.veth_xmit
... SNIP ....
d0000000021c096c  f821ff51      stdu    r1,-176(r1)
d0000000021c0970  7c3f0b78      mr      r31,r1
d0000000021c0974  7c7d1b78      mr      r29,r3
d0000000021c0978  7c992378      mr      r25,r4
d0000000021c097c  48000008      b       d0000000021c0984        #
.veth_xmit+0x38/0x26c [veth]
d0000000021c0980  e8410028      ld      r2,40(r1)
d0000000021c0984  e93d0088      ld      r9,136(r29)
d0000000021c0988  2fa90000      cmpdi   cr7,r9,0
1:mon> 
d0000000021c098c  419e0024      beq     cr7,d0000000021c09b0    #
.veth_xmit+0x64/0x26c [veth]
d0000000021c0990  e8090000      ld      r0,0(r9)
d0000000021c0994  f8410028      std     r2,40(r1)
....... SNIP .......
d0000000021c09d0  796b1f24      rldicr  r11,r11,3,60
d0000000021c09d4  7d4a50f8      not     r10,r10
d0000000021c09d8  e93a0008      ld      r9,8(r26)
d0000000021c09dc  7f8b502a      ldx     r28,r11,r10
  ^^^^^^^ points to %PC

The corresponding c code (veth_xmit) is:

 9cc:   3b 44 06 00     addi    r26,r4,1536

        cpu = smp_processor_id();
        stats = per_cpu_ptr(priv->stats, cpu);
 9d0:   79 6b 1f 24     rldicr  r11,r11,3,60
 9d4:   7d 4a 50 f8     not     r10,r10
        rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
 9d8:   e9 3a 00 08     ld      r9,8(r26)
        priv = netdev_priv(dev);
        rcv = priv->peer;
        rcv_priv = netdev_priv(rcv);

        cpu = smp_processor_id();
        stats = per_cpu_ptr(priv->stats, cpu);
 9dc:   7f 8b 50 2a     ldx     r28,r11,r10
        rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
 ^^^^^ PC points to this instruction ^^^^^

I haven't tried these tests earlier so not sure if this
is a new problem or not. Let me know if there is any
other information you would like.

Thanks
-Sachin

[1] -> http://downloads.sourceforge.net/ltp/ltp-full-20090531.tgz

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

