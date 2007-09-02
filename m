From: Mark Hindley <mark@hindley.org.uk>
Subject: [OOPS] 2.6.23-rc5 ? network/via-rhine [was: hang with
	CONFIG_MCYRIXIII]
Date: Sun, 2 Sep 2007 12:36:37 +0100
Message-ID: <20070902113637.GA3160@hindley.org.uk>
References: <20070902110401.GB4790@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 83-216-141-215.markhi700.adsl.metronet.co.uk ([83.216.141.215]:3254
	"EHLO mx.hindley.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964931AbXIBLgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 07:36:41 -0400
Content-Disposition: inline
In-Reply-To: <20070902110401.GB4790@hindley.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have now got an oops trace out of this box, which I presume has been
the cause of the previously observed hangs.

To my inexperienced eye it looks like it is related to via-rhine.

Thanks 

Mark
 
BUG: unable to handle kernel NULL pointer dereference at virtual address 00000025            
 printing eip:                                                                                                        
c0259a57                                                                                                              
*pde = 00000000                                                                                                       
Oops: 0000 [#1]                                                                                                       
PREEMPT                                                                                                               
Modules linked in: nfs cpufreq_userspace nfsd exportfs lockd sunrpc ppdev lp ac battery ipv6 sd_mod cpufreq_ondemand cpufreq_powersave longhaul af_packet tcp_diag inetv
CPU:    0                                                                                                             
EIP:    0060:[<c0259a57>]    Not tainted VLI                                                                          
EFLAGS: 00010246   (2.6.23-rc5 #1)                                                                                    
EIP is at tcp_rto_min+0x8/0x12                                                                                        
eax: 000000c8   ebx: c7ab1080   ecx: ffffffee   edx: 00000000                                                         
esi: c7ab1080   edi: 00000000   ebp: c9a24b20   esp: c0341dec                                                         
ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068                                                                    
Process ssh (pid: 4928, ti=c0341000 task=c963cf90 task.ti=c35b9000)                                                   
Stack: c0259b1b c7ab1080 c7ab1080 c025a2e8 c030c8a0 c025b906 00000080 00000080                                        
       c022f433 cacde032 00000000 00000000 00000001 28419aa8 731a8024 28419b18                                        
       00000000 00000000 c011ebc5 28419b18 00000282 028b585b 00000004 cceb3540                                        
Call Trace:                                                                                                           
 [<c0259b1b>] tcp_rtt_estimator+0xba/0x100                                                                            
 [<c025a2e8>] tcp_ack_saw_tstamp+0x14/0x43
 [<c025b906>] tcp_ack+0x6aa/0x1726
 [<c022f433>] skb_checksum+0x49/0x289
 [<c011ebc5>] local_bh_enable+0x5/0x8c
 [<c025f1bf>] tcp_rcv_established+0x344/0x5ed
 [<c024b660>] ip_route_input+0x3a/0xcdc
 [<c0264226>] tcp_v4_do_rcv+0x27/0x31d
 [<c0266309>] tcp_v4_rcv+0x71a/0x765
 [<c024e7b6>] ip_local_deliver+0x159/0x1bf
 [<c024e630>] ip_rcv+0x44e/0x47b
 [<c01b9540>] rb_insert_color+0x4c/0xad
 [<c024e630>] ip_rcv+0x44e/0x47b
 [<c0115bb4>] enqueue_entity+0x1d2/0x1f3
 [<c024e1e2>] ip_rcv+0x0/0x47b
 [<c023470b>] netif_receive_skb+0x30d/0x38e
 [<d00d55a8>] rhine_napipoll+0x2a7/0x46d [via_rhine]
 [<c02368c9>] net_rx_action+0x85/0x171
 [<c011ea8e>] __do_softirq+0x35/0x75
 [<c010665c>] do_softirq+0x3e/0x8d
 [<c013c6cc>] handle_level_irq+0x0/0xd0
 [<c011ea20>] irq_exit+0x29/0x62
 [<c010693b>] do_IRQ+0x94/0xad
 [<c0104cf3>] common_interrupt+0x23/0x30
 =======================
Code: 00 8b 14 24 8b 82 8c 02 00 00 89 82 10 04 00 00 a1 e0 6e 2f c0 89 82 14 04 00 00 83 c4 0c 5b 5e 5f 5d c3 8b 50 44 b8 c8 00 00 00 <f6> 42 25 20 74 03 8b 42 54 c3  
EIP: [<c0259a57>] tcp_rto_min+0x8/0x12 SS:ESP 0068:c0341dec
Kernel panic - not syncing: Fatal exception in interrupt

