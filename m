From: Enrico Demarin <enrico@superclick.com>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Sun, 13 Apr 2008 15:20:03 -0400
Message-ID: <48025CE3.7080807@superclick.com>
References: <47FFAFFA.7070802@superclick.com> <4801BB96.5010406@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040905070405040209070405"
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpre.hiport.it ([84.18.143.115]:25397 "EHLO hpre.hiport.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbYDMT0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 15:26:50 -0400
In-Reply-To: <4801BB96.5010406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040905070405040209070405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Patrick,

here it is, hope it will work out this time

- Enrico

Patrick McHardy wrote:
> Enrico Demarin wrote:
>> Kernel message
>> --------------
>>
>> BUG: soft lockup - CPU#0 stuck for 61s! 
>> [tc:5667]                                               Pid: 5667, 
>> comm: tc Not tainted (2.6.25-rc8 
>> #1)                                               EIP: 
>> 0060:[<c0282564>] EFLAGS: 00000287 CPU: 
>> 0                                              EIP is at 
>> qdisc_lookup+0x21/0x4b                                EAX: f7261224 
>> EBX: f7261000 ECX: f0de6300 EDX: 
>> f0de634c                                                       ESI: 
>> ffff0000 EDBUG: soft lockup - CPU#0 stuck for 61s!
> > ...
>
> This is unfortunately almost unreadable. Please resend the message
> as attachment.
>


--------------040905070405040209070405
Content-Type: text/plain;
 name="lockup.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lockup.txt"


BUG: soft lockup - CPU#0 stuck for 61s! [tc:5667]                                                

Pid: 5667, comm: tc Not tainted (2.6.25-rc8 #1)                                               
EIP: 0060:[<c0282564>] EFLAGS: 00000287 CPU: 0                                              
EIP is at qdisc_lookup+0x21/0x4b                                
EAX: f7261224 EBX: f7261000 ECX: f0de6300 EDX: f0de634c                                                       
ESI: ffff0000 EDBUG: soft lockup - CPU#0 stuck for 61s! [tc:5667]                                                                 

Pid: 5667, comm: tc Not tainted (2.6.25-rc8 #1)                                               
EIP: 0060:[<c0282564>] EFLAGS: 00000287 CPU: 0                                              
EIP is at qdisc_lookup+0x21/0x4b                                
EAX: f7261224 EBX: f7261000 ECX: f0de6300 EDX: f0de634c                                                       
ESI: ffff0000 EDI: f8ac4120 EBP:                                 
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068                                             
CR0: 80050033 CR2: 003c30d0 CR3: 36f09000 CR4: 000006d0                                                       
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000                                                       
DR6: ffff0ff0 DR7: 00000400                           
 [<c02828a4>] qdisc_tree_decrease_qlen+0x24/0x6f                                                
 [<f8b07c28>] htb_delete+0x97/0x12b [sch_htb]                                             
 [<c02835cf>] tc_ctl_tclass+0x1b4/0x231                                       
 [<c028341b>] ? tc_ctl_tclass+0x0/0x231                                       
 [<c027ea92>] rtnetlink_rcv_msg+0x181/0x18d                                           
 [<c027e911>] ? rtnetlink_rcv_msg+0x0/0x18d                                           
 [<c02887f7>] netlink_rcv_skb+0x38/0x83                                       
 [<c027eab5>] rtnetlink_rcv+0                           
 [<c028767f>] netlink_unicast+0x127/0x177                                         
 [<c0287ebf>] netlink_sendmsg+0x241/0x250                                         
 [<c026aee1>] sock_sendmsg+0xb8/0xcf                                    
 [<c026b08b>] ? sock_recvmsg+0xc2/0xda                                      
 [<c012ca68>] ? autoremove_wake_function+0x0/0x33                                                 
 [<c01dd0cd>] ? copy_from_user+0x3b/0x5e                                        
 [<c0271f34>] ? verify_iovec+0x40/0x74                                      
 [<c026c403>] sys_sendmsg+0x175/0x1dc                                     
 [<c0156cc1>] ? __do_fault+0x2d2/0x326                                      
 [<c0149554>] ? unlock_page+0x25/0x28                                     
 [<c0156cd5>] ? __do_fault+0x2e6/0x326                                      
 [<c0112a8b>] ? do_page_fault+0x1c0/0x406                                         
 [<c01369c7>] ? __lock_release+0                               
 [<c026c780>] sys_socketcall+0x164/0x17f                                        
 [<c01358ad>] ? trace_hardirqs_on+0xe1/0x102                                            
 [<c01036fe>] sysenter_past_esp+0x5f/0xa5                                         
 =======================                        
BUG: soft lockup - CPU#1 stuck for 61s! [ksoftirqd/1:7]                                                       

Pid: 7, comm: ksoftirqd/1 Not tainted (2.6.25-rc8 #1)                                                     
EIP: 0060:[<c010845f>] EFLAGS: 00000246 CPU: 1                                              
EIP is at native_read_tsc+0xe/0x13                                  
EAX: 16ae9694 EBX: 16ae9628 ECX: 00000001 EDX: 00000175                                                       
ESI: 00000001 EDI: f7261200 EBP: c0425de8 ESP: c0425de8                                                       
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068                                             
CR0: 8005003b CR2: 003e37b0 CR3: 00421000 CR4: 000006d0                                                       
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000                                                       
DR6: ffff0ff0 DR7: 00000400                           
 [<c01dc78a>] delay_tsc+0x15/0x1f                                 
 [<c01dc7ac>] __delay+0x9/0xb                             
 [<c01df94f>] __spin_lock_debug+0x56/0xab                                       
 [<c01dfa0d>] _raw_spin_lock+0x69/0x7e
 [<c02d4185>] _spin_lock+0x20/0x25
 [<c027520e>] ? dev_queue_xmit+0x171/0x2c1
 [<c027520e>] dev_queue_xmit+0x171/0x2c1
 [<c028a4b5>] ? nf_hook_slow+0xcf/0xda
 [<c0291f76>] ip_finish_output+0x1fc/0x237
 [<c0292373>] ip_output+0x83/0x88
 [<c0290a2f>] ip_forward_finish+0x2f/0x32
 [<c0290c5c>] ip_forward+0x22a/0x27a
 [<c028fbb3>] ip_rcv_finish+0x29d/0x2bc
 [<c028fde4>] ip_rcv+0x212/0x23e
 [<c0275861>] netif_receive_skb+0x28b/0x2be
 [<f899446b>] e1000_clean_rx_irq+0x3b7/0x468 [e1000]
 [<f8993d66>] e1000_clean+0x60/0xd8 [e1000]
 [<c0275a38>] net_rx_action+0x72/0x14c
 [<c0120b25>] __do_softirq+0x73/0xe6
 [<c0105b43>] do_softirq+0x5d/0xbd
 [<c0121000>] ksoftirqd+0x5b/0xc1
 [<c0120fa5>] ? ksoftirqd+0x0/0xc1
 [<c012c606>] kthread+0x37/0x59
 [<c012c5cf>] ? kthread+0x0/0x59
 [<c010440f>] kernel_thread_helper+0x7/0x10
 =======================

--------------040905070405040209070405
Content-Type: text/x-vcard; charset=utf-8;
 name="enrico.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="enrico.vcf"

begin:vcard
fn:Enrico Demarin
n:Demarin;Enrico
org:Superclick Networks;R&D
adr:;;10222 St Michel;Montreal;QC;H1H5H1;Canada
email;internet:enrico@superclick.com
title:Director
tel;work:514-847-0333x246
x-mozilla-html:FALSE
url:http://www.superclick.com
version:2.1
end:vcard


--------------040905070405040209070405--
