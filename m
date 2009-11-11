From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: Oops from tcp_collapse() when using splice()
Date: Wed, 11 Nov 2009 12:38:51 +0100
Message-ID: <4AFAA24B.9060706@hiramoto.org>
References: <4AFA9E81.3050508@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcbhh.dreamhost.com ([208.97.132.177]:38097 "EHLO
	spunkymail-a5.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753266AbZKKLiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 06:38:52 -0500
Received: from [192.168.10.51] (71.Red-83-44-146.dynamicIP.rima-tde.net [83.44.146.71])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by spunkymail-a5.g.dreamhost.com (Postfix) with ESMTP id E15002077E
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 03:38:56 -0800 (PST)
In-Reply-To: <4AFA9E81.3050508@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karl Hiramoto wrote:
> Hi, the following oops occurs with both 2.6.28.9 and 2.6.30.9
>
> userspace program is using  splice() on two tcp sockets.
>
 Unable to handle kernel NULL pointer dereference at virtual address 
00000000
pgd = 
c0004000                                                               
[00000000] 
*pgd=00000000                                                     
Internal error: Oops: 817 
[#1]                                               
Modules linked in: pppoe pppox br2684 crc_ccitt nf_nat_pptp 
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre af_key 
ixp4xx_crypto ipt_MASQUERADEc
CPU: 0    Not tainted  (2.6.30.9 
#1)                                                                                                                      

PC is at 
tcp_collapse+0x268/0x338                                                                                                                         

LR is at 
0xc2f047c0                                                                                                                                       

pc : [<c020be4c>]    lr : [<c2f047c0>]    psr: 
80000013                                                                                                   

sp : c0323c90  ip : c3881d40  fp : 
c0323cc8                                                                                                               

r10: c6762c80  r9 : 00000e2c  r8 : 
c3b85920                                                                                                               

r7 : c2f047a0  r6 : c3b85900  r5 : c2f04780  r4 : 
00000074                                                                                                

r3 : 00000000  r2 : c6766d84  r1 : 00004104  r0 : 
c2f04780                                                                                                

Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment 
kernel                                                                                       

Control: 000039ff  Table: 02cd0000  DAC: 
00000017                                                                                                         

Process swapper (pid: 0, stack limit = 
0xc0322260)                                                                                                        

Stack: (0xc0323c90 to 
0xc0324000)                                                                                                                         

3c80:                                     c3881d40 c3881d40 c3881ce0 
ffffc476                                                                             

3ca0: c3881ce0 c3881ce0 0000059a c2dd2d80 c2ea1054 c3882040 c2ea1054 
c0323d0c                                                                             

3cc0: c0323ccc c020c114 c020bbf0 c6762c80 c6773da0 b87d516b 00000000 
c3882040                                                                             

3ce0: 00000000 000008ec c3881ce0 0000059a c2dd2d80 c2ea1054 c2dd2da0 
c2ea1054                                                                             

3d00: c0323d40 c0323d10 c020c394 c020bf28 c2e46000 ffffffff c3881ce0 
c2dd2d80                                                                             

3d20: 0000059a c2ea1054 00000020 c2dd2da0 c2ea1054 c0323d6c c0323d44 
c02102f8                                                                             

3d40: c020c1b4 00000000 c2dd2d80 c3881ce0 c2ea1054 c03576fc c2ea1040 
0000e76d                                                                             

3d60: c0323d9c c0323d70 c0215770 c020fddc bf11dcfc 00000000 c0323d9c 
c0323d88                                                                             

3d80: 00000000 c2dd2d80 c3881ce0 c2ea1054 c0323dd8 c0323da0 c021750c 
c021574c                                                                             

3da0: 0a430f30 0000e76d 00000005 c0357e58 c033dd04 c2dd2d80 00000000 
c03576fc                                                                             

3dc0: c0358518 c033b870 00000000 c0323dfc c0323ddc c01fb6ac c0216e6c 
c2dd2d80                                                                             

3de0: c2dd2d80 c2ea1040 c2e46000 c0357a40 c0323e1c c0323e00 c01fbb68 
c01fb55c                                                                             

3e00: 00000000 c01fb550 80000000 c0357a20 c0323e48 c0323e20 c01fb52c 
c01fbaf8                                                                             

3e20: c2e46000 c2dd2d80 c0357a20 c2dd2d80 c03576fc c2e46000 c0357a40 
c0323e74                                                                             

3e40: c0323e4c c01fbab8 c01fb22c 00000000 c01fb220 80000000 c0357a20 
c2dd2d80                                                                             

3e60: c2e46000 00000800 c0323ea4 c0323e78 c01ddf24 c01fb86c c2e57a00 
c0323edc                                                                             

3e80: 00000002 c033b888 ffffabd7 00000040 00000000 c033b86c c0323ed0 
c0323ea8                                                                             

3ea0: c01ddff4 c01ddb9c c033b888 00000040 00000100 0000012c c033b86c 
c033b87c                                                                             

3ec0: ffffabd9 c0323efc c0323ed4 c01e095c c01ddf74 c0322000 0000000c 
00000100                                                                             

3ee0: 00000001 00000009 c034b72c 00000000 c0323f30 c0323f00 c00359dc 
c01e0900                                                                             

3f00: c0323f0c c0029608 00000003 00000000 00000008 c03426a8 0001c608 
690541f1                                                                             

3f20: 0001c49c c0323f40 c0323f34 c0035c98 c003597c c0323f58 c0323f44 
c0020058                                                                             

3f40: c0035c60 ffffffff 0000001f c0323fc0 c0323f5c c00209c4 c002000c 
c03273c8                                                                             

3f60: c381a900 a0000013 00000000 c0021de8 c0322000 c0021de8 c03426a8 
0001c608                                                                             

3f80: 690541f1 0001c49c c0323fc0 c0323fa4 c0323fa4 c0021cb0 c0021de8 
60000013                                                                             

3fa0: ffffffff c034dfc4 c0342450 c001dd60 c0326344 c0323fd0 c0323fc4 
c0263be4                                                                             

3fc0: c0021c80 c0323ff4 c0323fd4 c00089c0 c0263b98 c00083ac c001dd60 
000039fd                                                                             

3fe0: c03426d8 c001e164 00000000 c0323ff8 00008034 c00087bc 00000000 
00000000                                                                             

Backtrace:                                                                                                                                                

[<c020bbe4>] (tcp_collapse+0x0/0x338) from [<c020c114>] 
(tcp_prune_queue+0x1f8/0x28c)                                                                     

[<c020bf1c>] (tcp_prune_queue+0x0/0x28c) from [<c020c394>] 
(tcp_data_queue+0x1ec/0xc3c)
[<c020c1a8>] (tcp_data_queue+0x0/0xc3c) from [<c02102f8>] 
(tcp_rcv_established+0x528/0x5e0)
[<c020fdd0>] (tcp_rcv_established+0x0/0x5e0) from [<c0215770>] 
(tcp_v4_do_rcv+0x30/0x1c4)
[<c0215740>] (tcp_v4_do_rcv+0x0/0x1c4) from [<c021750c>] 
(tcp_v4_rcv+0x6ac/0x754)
 r7:c2ea1054 r6:c3881ce0 r5:c2dd2d80 r4:00000000
[<c0216e60>] (tcp_v4_rcv+0x0/0x754) from [<c01fb6ac>] 
(ip_local_deliver_finish+0x15c/0x21c)
[<c01fb550>] (ip_local_deliver_finish+0x0/0x21c) from [<c01fbb68>] 
(ip_local_deliver+0x7c/0x88)
 r8:c0357a40 r7:c2e46000 r6:c2ea1040 r5:c2dd2d80 r4:c2dd2d80
[<c01fbaec>] (ip_local_deliver+0x0/0x88) from [<c01fb52c>] 
(ip_rcv_finish+0x30c/0x330)
 r4:c0357a20
[<c01fb220>] (ip_rcv_finish+0x0/0x330) from [<c01fbab8>] 
(ip_rcv+0x258/0x28c)
 r8:c0357a40 r7:c2e46000 r6:c03576fc r5:c2dd2d80 r4:c0357a20
[<c01fb860>] (ip_rcv+0x0/0x28c) from [<c01ddf24>] 
(netif_receive_skb+0x394/0x3d8)
 r7:00000800 r6:c2e46000 r5:c2dd2d80 r4:c0357a20
[<c01ddb90>] (netif_receive_skb+0x0/0x3d8) from [<c01ddff4>] 
(process_backlog+0x8c/0xd8)
[<c01ddf68>] (process_backlog+0x0/0xd8) from [<c01e095c>] 
(net_rx_action+0x68/0x188)
[<c01e08f4>] (net_rx_action+0x0/0x188) from [<c00359dc>] 
(__do_softirq+0x6c/0xf8)
[<c0035970>] (__do_softirq+0x0/0xf8) from [<c0035c98>] (irq_exit+0x44/0x4c)
[<c0035c54>] (irq_exit+0x0/0x4c) from [<c0020058>] (asm_do_IRQ+0x58/0x6c)
[<c0020000>] (asm_do_IRQ+0x0/0x6c) from [<c00209c4>] (__irq_svc+0x24/0x80)
Exception stack(0xc0323f5c to 0xc0323fa4)
3f40:                                                                
c03273c8
3f60: c381a900 a0000013 00000000 c0021de8 c0322000 c0021de8 c03426a8 
0001c608
3f80: 690541f1 0001c49c c0323fc0 c0323fa4 c0323fa4 c0021cb0 c0021de8 
60000013
3fa0: ffffffff
 r5:0000001f r4:ffffffff
[<c0021c74>] (cpu_idle+0x0/0x58) from [<c0263be4>] (rest_init+0x58/0x6c)
 r7:c0326344 r6:c001dd60 r5:c0342450 r4:c034dfc4
[<c0263b8c>] (rest_init+0x0/0x6c) from [<c00089c0>] 
(start_kernel+0x210/0x264)
[<c00087b0>] (start_kernel+0x0/0x264) from [<00008034>] (0x8034)
 r6:c001e164 r5:c03426d8 r4:000039fd
Code: e50b302c e06a1002 5a000002 e3a03000 (e5833000)
