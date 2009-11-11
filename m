From: Karl Hiramoto <karl@hiramoto.org>
Subject: Oops from tcp_collapse() when using splice()
Date: Wed, 11 Nov 2009 12:22:41 +0100
Message-ID: <4AFA9E81.3050508@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:34008 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbZKKLXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 06:23:19 -0500
Received: from spunkymail-a1.g.dreamhost.com (caiajhbdcaib.dreamhost.com [208.97.132.81])
	by hapkido.dreamhost.com (Postfix) with ESMTP id CFC6217E15A
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 03:23:24 -0800 (PST)
Received: from [192.168.10.51] (71.Red-83-44-146.dynamicIP.rima-tde.net [83.44.146.71])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by spunkymail-a1.g.dreamhost.com (Postfix) with ESMTP id E9D93FE21B
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 03:22:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, the following oops occurs with both 2.6.28.9 and 2.6.30.9

userspace program is using  splice() on two tcp sockets.


Internal error: Oops: 817 [#1]                                                                         
Modules linked in: pppoe pppox br2684 crc_ccitt nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre af_key ixp4xx_crypto ipt_MASQUERADE
CPU: 0    Not tainted  (2.6.30.9 #1)                                                                                                                      
PC is at tcp_collapse+0x268/0x338                                                                                                                         
LR is at 0xc2c49640                                                                                                                                       
pc : [<c020be4c>]    lr : [<c2c49640>]    psr: 80000013                                                                                                   
sp : c0323c80  ip : c3a09920  fp : c0323cb8                                                                                                               
r10: 20ec0490  r9 : 00000e2c  r8 : c2d117a0                                                                                                               
r7 : c2c49620  r6 : c2d11780  r5 : c2c49600  r4 : 00000074                                                                                                
r3 : 00000000  r2 : 20ec4594  r1 : 00004104  r0 : c2c49600                                                                                                
Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel                                                                                       
Control: 000039ff  Table: 02efc000  DAC: 00000017                                                                                                         
Process swapper (pid: 0, stack limit = 0xc0322260)                                                                                                        
Stack: (0xc0323c80 to 0xc0324000)                                                                                                                         
3c80: c3a09920 c3a09920 c3a098c0 ffffc476 c3a098c0 c3a098c0 0000059a c2cded80                                                                             
3ca0: c2eef054 c3a09c20 c2eef054 c0323cfc c0323cbc c020c114 c020bbf0 20ec0490                                                                             
3cc0: 20ed15b0 18295345 00000000 c3a09c20 00000000 000008ec c3a098c0 0000059a                                                                             
3ce0: c2cded80 c2eef054 c2cdeda0 c2eef054 c0323d30 c0323d00 c020c394 c020bf28                                                                             
3d00: c2e5ec00 ffffffff c3a098c0 c2cded80 0000059a c2eef054 00000020 c2cdeda0                                                                             
3d20: c2eef054 c0323d5c c0323d34 c02102f8 c020c1b4 00000000 c2cded80 c3a098c0                                                                             
3d40: c2eef054 c03576fc c2eef040 0000cd2b c0323d8c c0323d60 c0215770 c020fddc                                                                             
3d60: bf11dcfc 00000000 c0323d8c c0323d78 00000000 c2cded80 c3a098c0 c2eef054                                                                             
3d80: c0323dc8 c0323d90 c021750c c021574c 0a430f2d 0000cd2b 00000005 c0357e58                                                                             
3da0: c033dd04 c2cded80 00000000 c03576fc c0358518 c033b870 00000000 c0323dec                                                                             
3dc0: c0323dcc c01fb6ac c0216e6c c2cded80 c2cded80 c2eef040 c2e5ec00 c0357a40                                                                             
3de0: c0323e0c c0323df0 c01fbb68 c01fb55c 00000000 c01fb550 80000000 c0357a20                                                                             
3e00: c0323e38 c0323e10 c01fb52c c01fbaf8 c2e5ec00 c2cded80 c0357a20 c2cded80                                                                             
3e20: c03576fc c2e5ec00 c0357a40 c0323e64 c0323e3c c01fbab8 c01fb22c 00000000                                                                             
3e40: c01fb220 80000000 c0357a20 c2cded80 c2e5ec00 00000800 c0323e94 c0323e68                                                                             
3e60: c01ddf24 c01fb86c c2e5c600 c0323ecc 00000002 c033b888 ffffbe5e 00000040                                                                             
3e80: 00000000 c033b86c c0323ec0 c0323e98 c01ddff4 c01ddb9c c033b888 00000040                                                                             
3ea0: 00000100 0000012c c033b86c c033b87c ffffbe60 c0323eec c0323ec4 c01e095c                                                                             
3ec0: c01ddf74 c0322000 0000000c 00000100 00000001 00000009 c034b72c 00000000                                                                             
3ee0: c0323f20 c0323ef0 c00359dc c01e0900 c0323efc c0029608 00000003 00000000                                                                             
3f00: 00000008 c03426a8 0001c608 690541f1 0001c49c c0323f30 c0323f24 c0035c98                                                                             
3f20: c003597c c0323f48 c0323f34 c0020058 c0035c60 ffffffff 0000001f c0323fa0                                                                             
3f40: c0323f4c c00209c4 c002000c c03273c8 c383e300 c0322000 00000000 c0021de8                                                                             
3f60: c0322000 c0021de8 c03426a8 0001c608 690541f1 0001c49c c0323fa0 c0323fa4                                                                             
3f80: c0323f94 c0021cb0 c0021dfc 60000013 ffffffff c0323fc0 c0323fa4 c0021cb0                                                                             
3fa0: c0021df4 c034dfc4 c0342450 c001dd60 c0326344 c0323fd0 c0323fc4 c0263be4                                                                             
3fc0: c0021c80 c0323ff4 c0323fd4 c00089c0 c0263b98 c00083ac c001dd60 000039fd                                                                             
3fe0: c03426d8 c001e164 00000000 c0323ff8 00008034 c00087bc 00000000 00000000                                                                             
Backtrace:                                                                                                                                                
[<c020bbe4>] (tcp_collapse+0x0/0x338) from [<c020c114>] (tcp_prune_queue+0x1f8/0x28c)                                                                     
[<c020bf1c>] (tcp_prune_queue+0x0/0x28c) from [<c020c394>] (tcp_data_queue+0x1ec/0xc3c)                                                                   
[<c020c1a8>] (tcp_data_queue+0x0/0xc3c) from [<c02102f8>] (tcp_rcv_established+0x528/0x5e0)                                                               
[<c020fdd0>] (tcp_rcv_established+0x0/0x5e0) from [<c0215770>] (tcp_v4_do_rcv+0x30/0x1c4)                                                                 
[<c0215740>] (tcp_v4_do_rcv+0x0/0x1c4) from [<c021750c>] (tcp_v4_rcv+0x6ac/0x754)                                                                         
 r7:c2eef054 r6:c3a098c0 r5:c2cded80 r4:00000000                                                                                                          
[<c0216e60>] (tcp_v4_rcv+0x0/0x754) from [<c01fb6ac>] (ip_local_deliver_finish+0x15c/0x21c)                                                               
[<c01fb550>] (ip_local_deliver_finish+0x0/0x21c) from [<c01fbb68>] (ip_local_deliver+0x7c/0x88)                                                           
 r8:c0357a40 r7:c2e5ec00 r6:c2eef040 r5:c2cded80 r4:c2cded80                                                                                              
[<c01fbaec>] (ip_local_deliver+0x0/0x88) from [<c01fb52c>] (ip_rcv_finish+0x30c/0x330)                                                                    
 r4:c0357a20                                                                                                                                              
[<c01fb220>] (ip_rcv_finish+0x0/0x330) from [<c01fbab8>] (ip_rcv+0x258/0x28c)                                                                             
 r8:c0357a40 r7:c2e5ec00 r6:c03576fc r5:c2cded80 r4:c0357a20                                                                                              
[<c01fb860>] (ip_rcv+0x0/0x28c) from [<c01ddf24>] (netif_receive_skb+0x394/0x3d8)                                                                         
 r7:00000800 r6:c2e5ec00 r5:c2cded80 r4:c0357a20                                                                                                          
[<c01ddb90>] (netif_receive_skb+0x0/0x3d8) from [<c01ddff4>] (process_backlog+0x8c/0xd8)                                                                  
[<c01ddf68>] (process_backlog+0x0/0xd8) from [<c01e095c>] (net_rx_action+0x68/0x188)                                                                      
[<c01e08f4>] (net_rx_action+0x0/0x188) from [<c00359dc>] (__do_softirq+0x6c/0xf8)                                                                         
[<c0035970>] (__do_softirq+0x0/0xf8) from [<c0035c98>] (irq_exit+0x44/0x4c)                                                                               
[<c0035c54>] (irq_exit+0x0/0x4c) from [<c0020058>] (asm_do_IRQ+0x58/0x6c)                                                                                 
[<c0020000>] (asm_do_IRQ+0x0/0x6c) from [<c00209c4>] (__irq_svc+0x24/0x80)                                                                                
Exception stack(0xc0323f4c to 0xc0323f94)                                                                                                                 
3f40:                            c03273c8 c383e300 c0322000 00000000 c0021de8                                                                             
3f60: c0322000 c0021de8 c03426a8 0001c608 690541f1 0001c49c c0323fa0 c0323fa4                                                                             
3f80: c0323f94 c0021cb0 c0021dfc 60000013 ffffffff                                                                                                        
 r5:0000001f r4:ffffffff                                                                                                                                  
[<c0021de8>] (default_idle+0x0/0x4c) from [<c0021cb0>] (cpu_idle+0x3c/0x58)                                                                               
[<c0021c74>] (cpu_idle+0x0/0x58) from [<c0263be4>] (rest_init+0x58/0x6c)                                                                                  
 r7:c0326344 r6:c001dd60 r5:c0342450 r4:c034dfc4                                                                                                          
[<c0263b8c>] (rest_init+0x0/0x6c) from [<c00089c0>] (start_kernel+0x210/0x264)                                                                            
[<c00087b0>] (start_kernel+0x0/0x264) from [<00008034>] (0x8034)                                                                                          
 r6:c001e164 r5:c03426d8 r4:000039fd                                                                                                                      
Code: e50b302c e06a1002 5a000002 e3a03000 (e5833000) 

