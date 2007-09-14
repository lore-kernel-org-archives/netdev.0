From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc4-mm1 list_add corruption in networking code
Date: Fri, 14 Sep 2007 13:47:03 -0700
Message-ID: <20070914134703.c66889c9.akpm@linux-foundation.org>
References: <20070914140803.GA26161@Krystal>
	<20070914092552.ebccdaa9.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37035 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757464AbXINUsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 16:48:10 -0400
In-Reply-To: <20070914092552.ebccdaa9.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Sep 2007 09:25:52 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> [adding netdev]

yup.      I wonder if the net developers are setting CONFIG_DEBUG_LIST

> On Fri, 14 Sep 2007 10:08:03 -0400 Mathieu Desnoyers wrote:
> 
> > Hi Andrew,
> > 
> > My P4 is crashing about once a day, started with 2.6.23-rc4-mm1, with
> > errors that seems related to network code. Here is the latest BUG:
> > (sorry, my console log cuts it at 80 cols)
> > 
> > Mathieu
> > 
> > [ 4590.836342] list_add corruption. prev->next should be next (c1df4a10), but w 
> > [ 4590.864914] ------------[ cut here ]------------                             
> > [ 4590.878687] Kernel BUG at c0263cbc [verbose debug info unavailable]          
> > [ 4590.897389] invalid opcode: 0000 [#1] PREEMPT SMP                            
> > [ 4590.911721] last sysfs file: /block/sda/size                                 
> > [ 4590.924453] Modules linked in: snd_hda_intel usbserial rtc pl2303 skge sky2  
> > [ 4590.945324]                                                                  
> > [ 4590.949752] Pid: 3283, comm: cc1 Not tainted (2.6.23-rc4-mm1-testssmp #334)  
> > [ 4590.970525] EIP: 0060:[<c0263cbc>] EFLAGS: 00010082 CPU: 0                   
> > [ 4590.986895] EIP is at __list_add+0x5c/0x60                                   
> > [ 4590.999111] EAX: 00000070 EBX: c2b3b4e8 ECX: 00000001 EDX: 00000203          
> > [ 4591.017812] ESI: c2b3b4e8 EDI: 00000202 EBP: c3eb7b34 ESP: c3eb7b1c          
> > [ 4591.036511]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068                   )
> > [ 4591.052621] Process cc1 (pid: 3283, ti=c3eb6000 task=c2073ea0 task.ti=c3eb60 
> > [ 4591.073917] Stack: c04dcd50 c1df4a10 c2b3b4e8 c2b3b4e8 c05b3d00 00000006 c3e 
> > [ 4591.098997]        c1df49e0 c20a499c c3eb7b58 c03afdaf c20a499c c054d4e0 c05
> > [ 4591.149154] Call Trace:                                                      
> > [ 4591.156974]  [<c010971a>] show_trace_log_lvl+0x1a/0x30                       
> > [ 4591.172332]  [<c01097d8>] show_stack_log_lvl+0xa8/0xe0                       
> > [ 4591.187685]  [<c01098da>] show_registers+0xca/0x250                          
> > [ 4591.202264]  [<c0109b75>] die+0x115/0x280                                    
> > [ 4591.214247]  [<c0109d71>] do_trap+0x91/0xc0                                  
> > [ 4591.226748]  [<c010a119>] do_invalid_op+0x89/0xa0                            
> > [ 4591.240808]  [<c0423e7a>] error_code+0x72/0x78                               
> > [ 4591.254091]  [<c03aee41>] __napi_schedule+0x51/0xb0                          
> > [ 4591.268667]  [<c03afdaf>] netif_rx+0x14f/0x160                               
> > [ 4591.281946]  [<c02de090>] loopback_xmit+0x60/0x70                            
> > [ 4591.296006]  [<c03b02fb>] dev_hard_start_xmit+0x22b/0x300                    
> > [ 4591.312142]  [<c03b2695>] dev_queue_xmit+0x295/0x350                         
> > [ 4591.326979]  [<c03ceaa9>] ip_output+0x199/0x330                              
> > [ 4591.340519]  [<c03cdf96>] ip_queue_xmit+0x1c6/0x3e0                          
> > [ 4591.355104]  [<c03dec4b>] tcp_transmit_skb+0x3db/0x770                       
> > [ 4591.370462]  [<c03df9c3>] tcp_write_wakeup+0xf3/0x150                        
> > [ 4591.385562]  [<c03e18fb>] tcp_send_probe0+0xb/0xe0                           
> > [ 4591.399885]  [<c03e23dc>] tcp_write_timer+0x13c/0x720                        
> > [ 4591.414982]  [<c013af80>] run_timer_softirq+0x120/0x190                      
> > [ 4591.430600]  [<c0136d53>] __do_softirq+0x93/0x120                     
> > [ 4591.444662]  [<c0136e85>] do_softirq+0xa5/0xb0                               
> > [ 4591.457943]  [<c0137084>] irq_exit+0x54/0x60                                 
> > [ 4591.470704]  [<c010b425>] do_IRQ+0x45/0x80                                   
> > [ 4591.482951]  [<c0108fce>] common_interrupt+0x2e/0x34                         
> > [ 4591.497798]  [<c016d791>] file_read_actor+0xe1/0x100                         
> > [ 4591.512641]  [<c016e134>] do_generic_mapping_read+0x1f4/0x440                
> > [ 4591.529815]  [<c016fbfe>] generic_file_aio_read+0xbe/0x1c0                   
> > [ 4591.546217]  [<c019138e>] do_sync_read+0xce/0x110                            
> > [ 4591.560282]  [<c0191be4>] vfs_read+0x94/0x130                                
> > [ 4591.573310]  [<c019212d>] sys_read+0x3d/0x70                                 
> > [ 4591.586075]  [<c0108596>] syscall_call+0x7/0xb                               
> > [ 4591.599357]  =======================                                         
> > [ 4591.610015] INFO: lockdep is turned off.                                     
> > [ 4591.621713] Code: 5c 24 04 c7 04 24 00 cd 4d c0 e8 40 e1 ec ff 0f 0b eb fe 8 
> > [ 4591.679092] EIP: [<c0263cbc>] __list_add+0x5c/0x60 SS:ESP 0068:c3eb7b1c      
> > [ 4591.698884] Kernel panic - not syncing: Fatal exception in interrupt        

We're doing NAPI stuff on the loopback device??


