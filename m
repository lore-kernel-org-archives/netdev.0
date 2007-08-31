From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 11:04:21 +0400
Message-ID: <46D7BD75.3080008@bigtelecom.ru>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030801050200020809080400"
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:54315 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759654AbXHaHEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 03:04:25 -0400
In-Reply-To: <20070830123751.GA2778@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030801050200020809080400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


I try you patch. Also i try add more debug options to kernel. I catch 
(BUG: spinlock lockup on CPU#3, tc/6403, f742e200)
All info in file. Ready for next patch ;)

>> Jarek Poplawski ??????????:
>>     
> ...
>   
>>> On the other hand disabling local interrupts shouldn't be enough here,
>>> so it's really strange... Did you get this remotely? Are you sure LOC
>>> only? (Anyway this 2.6.23-rc4 should be interesting.)
>>>       
> ...
>   
>> Only LOC changes... icmp answer = 50-70ms... after 1-2 hours traffic 
>> level is down and SI on CPU0 and CPU2 change to above 50%. ksoftirqd 
>> free CPU usage. I have this bug 3-4 times in week. If you need info what 
>> i can see only in bug still processing - i may try get this info for you.
>>     
>
> Any additional info could be helpful. I'm not sure if all these
> computers do similar htb processing, or it's another problem?
> As I've written before htb before 2.6.23-rc1 has a problem with
> timer lockup during qdisc_destroy, so softirqs would be hit.
> If it's htb's fault 2.6.23-rc4 or my testing patch should help.
>
> I try to find in htb code another weak points. BTW, if during
> such lockups any processes are killed 'by hand' etc., without
> restarting the whole system, please let us know.
>
>   
>> maybe help:
>>
>> 1U server INTEL, mb se7501w2
>>
>> nat-new ~ # lspci
>>     
>
> lspci -v (or -vv should be more usable - but with dmesg at least)
>
> Jarek P.
>
>
>   


--------------030801050200020809080400
Content-Type: text/plain;
 name="bug.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bug.txt"


[  133.592929] HTB: quantum of class 10002 is big. Consider r2q change.
[  133.606638] HTB: quantum of class 10004 is big. Consider r2q change.
[  133.609442] HTB: quantum of class 10005 is big. Consider r2q change.
[  133.612331] HTB: quantum of class 10007 is big. Consider r2q change.
[  133.615099] HTB: quantum of class 10008 is big. Consider r2q change.
[  133.624105] HTB: quantum of class 10002 is big. Consider r2q change.
[  133.628133] HTB: quantum of class 10004 is big. Consider r2q change.
[  133.630870] HTB: quantum of class 10005 is big. Consider r2q change.
[  133.633649] HTB: quantum of class 10007 is big. Consider r2q change.
[  133.636379] HTB: quantum of class 10008 is big. Consider r2q change.
[  133.648717] u32 classifier
[  133.648839]     Performance counters on
[  133.648957]     input device check on 
[  133.649064]     Actions configured 
[  135.430122] WARNING: at net/sched/sch_htb.c:404 htb_safe_rb_erase()
[  135.430322]  [<f88394c5>] htb_deactivate_prios+0x135/0x18c [sch_htb]
[  135.430491]  [<f883addd>] htb_dequeue+0x468/0x6d6 [sch_htb]
[  135.430643]  [<c02bcf9b>] __qdisc_run+0x1e/0x190
[  135.430801]  [<c02b352c>] dev_queue_xmit+0x152/0x266
[  135.430920]  [<c02b7a40>] neigh_resolve_output+0x1f2/0x224
[  135.431085]  [<c02ceaee>] ip_output+0x28f/0x2bd
[  135.431261]  [<c02cbd94>] dst_output+0x0/0x7
[  135.431419]  [<c02ce48b>] ip_build_and_send_pkt+0x1da/0x1ef
[  135.431560]  [<c02cbd94>] dst_output+0x0/0x7
[  135.431698]  [<c02dfbed>] tcp_v4_send_synack+0x9f/0xf3
[  135.431842]  [<c02e140a>] tcp_v4_conn_request+0x379/0x3ae
[  135.431979]  [<c02c6913>] rt_intern_hash+0x31f/0x331
[  135.432121]  [<c02da4f5>] tcp_rcv_state_process+0x62/0xad1
[  135.432265]  [<c02e090a>] tcp_v4_do_rcv+0x2be/0x311
[  135.432405]  [<c02e2938>] tcp_v4_rcv+0x86a/0x8de
[  135.432547]  [<c02c9ec9>] ip_local_deliver+0x18b/0x232
[  135.432683]  [<c02c9608>] ip_local_deliver_finish+0x0/0x1b2
[  135.432824]  [<c02c9d05>] ip_rcv+0x484/0x4bd
[  135.432962]  [<c02b155f>] netif_receive_skb+0x2bc/0x32b
[  135.433105]  [<c023ca05>] e1000_clean_rx_irq+0x375/0x444
[  135.433252]  [<c023c690>] e1000_clean_rx_irq+0x0/0x444
[  135.433388]  [<c023baa9>] e1000_clean+0x7a/0x249
[  135.433528]  [<c02b32e6>] net_rx_action+0x91/0x185
[  135.433668]  [<c011c8c6>] __do_softirq+0x5d/0xc1
[  135.433806]  [<c011c95c>] do_softirq+0x32/0x36
[  135.433939]  [<c01043e6>] do_IRQ+0x7e/0x90
[  135.434075]  [<c010d65d>] smp_apic_timer_interrupt+0x74/0x80
[  135.434219]  [<c010c7c5>] smp_call_function_interrupt+0x3c/0x52
[  135.434352]  [<c0102f1f>] common_interrupt+0x23/0x28
[  135.434488]  [<c0100ab1>] mwait_idle_with_hints+0x3b/0x3f
[  135.434627]  [<c0100bbc>] cpu_idle+0x59/0x6e
[  135.434765]  [<c0421bcd>] start_kernel+0x2ea/0x2f2
[  135.434908]  [<c0421440>] unknown_bootoption+0x0/0x202
[  135.435044]  =======================
[  140.454198] WARNING: at net/sched/sch_htb.c:404 htb_safe_rb_erase()
[  140.454311]  [<f88394c5>] htb_deactivate_prios+0x135/0x18c [sch_htb]
[  140.454469]  [<f883addd>] htb_dequeue+0x468/0x6d6 [sch_htb]
[  140.454616]  [<c02bcf9b>] __qdisc_run+0x1e/0x190
[  140.454764]  [<c02b352c>] dev_queue_xmit+0x152/0x266
[  140.454910]  [<c02b7a40>] neigh_resolve_output+0x1f2/0x224
[  140.455053]  [<c02ceaee>] ip_output+0x28f/0x2bd
[  140.455199]  [<c02cbd94>] dst_output+0x0/0x7
[  140.455341]  [<c02cc13d>] ip_push_pending_frames+0x2f2/0x3b6
[  140.455484]  [<c02cbd94>] dst_output+0x0/0x7
[  140.455625]  [<c02cde53>] ip_send_reply+0x1a2/0x1f8
[  140.455772]  [<c0303e1b>] _read_unlock_bh+0x5/0xd
[  140.455914]  [<c02dfb1f>] tcp_v4_send_reset+0x10c/0x13b
[  140.456059]  [<c02e2948>] tcp_v4_rcv+0x87a/0x8de
[  140.456202]  [<c02c9ec9>] ip_local_deliver+0x18b/0x232
[  140.456343]  [<c02c9608>] ip_local_deliver_finish+0x0/0x1b2
[  140.456490]  [<c02c9d05>] ip_rcv+0x484/0x4bd
[  140.456633]  [<c023c5cb>] e1000_alloc_rx_buffers+0x1bb/0x280
[  140.456784]  [<c02b155f>] netif_receive_skb+0x2bc/0x32b
[  140.456925]  [<c023ca05>] e1000_clean_rx_irq+0x375/0x444
[  140.457069]  [<c023c690>] e1000_clean_rx_irq+0x0/0x444
[  140.457210]  [<c023baa9>] e1000_clean+0x7a/0x249
[  140.457351]  [<c02b32e6>] net_rx_action+0x91/0x185
[  140.457493]  [<c011c8c6>] __do_softirq+0x5d/0xc1
[  140.457637]  [<c011c95c>] do_softirq+0x32/0x36
[  140.457781]  [<c01043e6>] do_IRQ+0x7e/0x90
[  140.457924]  [<c010d65d>] smp_apic_timer_interrupt+0x74/0x80
[  140.458068]  [<c010c7c5>] smp_call_function_interrupt+0x3c/0x52
[  140.458212]  [<c0102f1f>] common_interrupt+0x23/0x28
[  140.458354]  [<c0100ab1>] mwait_idle_with_hints+0x3b/0x3f
[  140.458495]  [<c0100bbc>] cpu_idle+0x59/0x6e
[  140.458635]  [<c0421bcd>] start_kernel+0x2ea/0x2f2
[  140.458783]  [<c0421440>] unknown_bootoption+0x0/0x202
[  140.458925]  =======================
[  383.290939] BUG: spinlock lockup on CPU#3, tc/6403, f742e200
[  383.291058]  [<c01c5fe9>] _raw_spin_lock+0xbb/0xdc
[  383.291203]  [<c02bcb1d>] qdisc_lock_tree+0x14/0x1c
[  383.291346]  [<f883a22e>] htb_change_class+0x23a/0x505 [sch_htb]
[  383.291495]  [<c02bda57>] tc_ctl_tclass+0x1ae/0x1fd
[  383.291633]  [<c02bd8a9>] tc_ctl_tclass+0x0/0x1fd
[  383.291774]  [<c02b8898>] rtnetlink_rcv_msg+0x18d/0x1a7
[  383.291911]  [<c02c2a16>] netlink_run_queue+0x65/0xdb
[  383.292055]  [<c02b870b>] rtnetlink_rcv_msg+0x0/0x1a7
[  383.292195]  [<c02b86c7>] rtnetlink_rcv+0x25/0x3d
[  383.292332]  [<c02c2e58>] netlink_data_ready+0x12/0x52
[  383.292468]  [<c02c1e92>] netlink_sendskb+0x1c/0x33
[  383.292605]  [<c02c2e3a>] netlink_sendmsg+0x23b/0x247
[  383.292746]  [<c02a837b>] sock_sendmsg+0xbc/0xd4
[  383.292890]  [<c0127bad>] autoremove_wake_function+0x0/0x35
[  383.293035]  [<c0127bad>] autoremove_wake_function+0x0/0x35
[  383.293179]  [<c01c44a3>] copy_from_user+0x2d/0x59
[  383.293314]  [<c02ae8d9>] verify_iovec+0x3e/0x6d
[  383.293452]  [<c02a8527>] sys_sendmsg+0x194/0x1f9
[  383.293590]  [<c02a8d9b>] sys_recvmsg+0x14d/0x1cf
[  383.293727]  [<c01c44a3>] copy_from_user+0x2d/0x59
[  383.293864]  [<c013bfc4>] __alloc_pages+0x63/0x297
[  383.294004]  [<c0143be0>] __handle_mm_fault+0x7bd/0x7ef
[  383.294148]  [<c02ab565>] sock_def_write_space+0x15/0x8e
[  383.294284]  [<c02ab054>] sock_setsockopt+0x4bb/0x4c5
[  383.295769]  [<c02a949a>] sys_socketcall+0x223/0x242
[  383.295911]  [<c030520e>] do_page_fault+0x0/0x534
[  383.296051]  [<c010250e>] sysenter_past_esp+0x5f/0x85
[  383.296192]  =======================

############# SYSTEM IS FREEZE. reboot on panic not work. Reboot manual

[   30.748000] HTB: quantum of class 10002 is big. Consider r2q change.
[   30.774000] HTB: quantum of class 10004 is big. Consider r2q change.
[   30.777000] HTB: quantum of class 10005 is big. Consider r2q change.
[   30.779000] HTB: quantum of class 10007 is big. Consider r2q change.
[   30.782000] HTB: quantum of class 10008 is big. Consider r2q change.
[   30.790000] HTB: quantum of class 10002 is big. Consider r2q change.
[   30.794000] HTB: quantum of class 10004 is big. Consider r2q change.
[   30.797000] HTB: quantum of class 10005 is big. Consider r2q change.
[   30.800000] HTB: quantum of class 10007 is big. Consider r2q change.
[   30.803000] HTB: quantum of class 10008 is big. Consider r2q change.
[   30.815000] u32 classifier
[   30.815000]     Performance counters on
[   30.815000]     input device check on 
[   30.816000]     Actions configured 
[   32.684000] WARNING: at net/sched/sch_htb.c:404 htb_safe_rb_erase()
[   32.684000]  [<f88394c5>] htb_deactivate_prios+0x135/0x18c [sch_htb]
[   32.684000]  [<f883addd>] htb_dequeue+0x468/0x6d6 [sch_htb]
[   32.684000]  [<c02bcf9b>] __qdisc_run+0x1e/0x190
[   32.684000]  [<c02b352c>] dev_queue_xmit+0x152/0x266
[   32.684000]  [<c02b7a40>] neigh_resolve_output+0x1f2/0x224
[   32.684000]  [<c02ceaee>] ip_output+0x28f/0x2bd
[   32.684000]  [<c02cbd94>] dst_output+0x0/0x7
[   32.684000]  [<c02ce1c2>] ip_queue_xmit+0x319/0x35e
[   32.684000]  [<c02cbd94>] dst_output+0x0/0x7
[   32.684000]  [<c02c700a>] __ip_route_output_key+0x6e5/0x6ff
[   32.684000]  [<c02e0fd3>] tcp_v4_send_check+0x80/0xb6
[   32.684000]  [<c02dc494>] tcp_transmit_skb+0x65c/0x68f
[   32.684000]  [<c02ad694>] __alloc_skb+0x49/0xf5
[   32.684000]  [<c02de876>] tcp_connect+0x2a8/0x327
[   32.684000]  [<c02e1a15>] tcp_v4_connect+0x468/0x586
[   32.684000]  [<c02ec4d5>] inet_stream_connect+0x7f/0x1ff
[   32.684000]  [<c013e195>] mark_page_accessed+0x1c/0x30
[   32.684000]  [<c01c44a3>] copy_from_user+0x2d/0x59
[   32.684000]  [<c02a7eca>] sys_connect+0x72/0x9c
[   32.684000]  [<c02a9d5f>] release_sock+0x13/0x94
[   32.684000]  [<c02e0b3f>] tcp_v4_init_sock+0x6f/0x141
[   32.684000]  [<c0303e2d>] _spin_unlock_bh+0x5/0xd
[   32.684000]  [<c02ab054>] sock_setsockopt+0x4bb/0x4c5
[   32.684000]  [<c0161002>] d_instantiate+0x3f/0x4c
[   32.684000]  [<c02a7e22>] sys_setsockopt+0x53/0x89
[   32.684000]  [<c02a9306>] sys_socketcall+0x8f/0x242
[   32.684000]  [<c010250e>] sysenter_past_esp+0x5f/0x85
[   32.684000]  =======================

### System is freeze. Keyboard not work. reboot on panic not work. Reboot
manual

[  127.698542] HTB: quantum of class 10002 is big. Consider r2q change.
[  127.722805] HTB: quantum of class 10004 is big. Consider r2q change.
[  127.725820] HTB: quantum of class 10005 is big. Consider r2q change.
[  127.728585] HTB: quantum of class 10007 is big. Consider r2q change.
[  127.731314] HTB: quantum of class 10008 is big. Consider r2q change.
[  127.743386] HTB: quantum of class 10002 is big. Consider r2q change.
[  127.747382] HTB: quantum of class 10004 is big. Consider r2q change.
[  127.750136] HTB: quantum of class 10005 is big. Consider r2q change.
[  127.752952] HTB: quantum of class 10007 is big. Consider r2q change.
[  127.755631] WARNING: at net/sched/sch_htb.c:404 htb_safe_rb_erase()
[  127.755692] HTB: quantum of class 10008 is big. Consider r2q change.
[  127.755853]  [<f88394c5>] htb_deactivate_prios+0x135/0x18c [sch_htb]
[  127.756000]  [<f883addd>] htb_dequeue+0x468/0x6d6 [sch_htb]
[  127.756144]  [<c01d7148>] extract_entropy+0x45/0x89
[  127.756289]  [<c02bcf9b>] __qdisc_run+0x1e/0x190
[  127.756434]  [<c02b352c>] dev_queue_xmit+0x152/0x266
[  127.756574]  [<c02e80d0>] arp_send+0x4c/0x64
[  127.756720]  [<c02e76d2>] arp_xmit+0x4d/0x51
[  127.756857]  [<c02e839b>] arp_process+0x2b3/0x50b
[  127.757001]  [<c013a5dc>] mempool_free+0x66/0x6b
[  127.757151]  [<c0303ed7>] _spin_lock_irqsave+0x9/0xd
[  127.757291]  [<c01d6c48>] __add_entropy_words+0x58/0x184
[  127.757430]  [<c02e86e2>] arp_rcv+0xef/0x103
[  127.757567]  [<c02b155f>] netif_receive_skb+0x2bc/0x32b
[  127.757705]  [<c023ca05>] e1000_clean_rx_irq+0x375/0x444
[  127.757853]  [<c023c690>] e1000_clean_rx_irq+0x0/0x444
[  127.757990]  [<c023baa9>] e1000_clean+0x7a/0x249
[  127.758126]  [<c02b32e6>] net_rx_action+0x91/0x185
[  127.758264]  [<c011c8c6>] __do_softirq+0x5d/0xc1
[  127.758404]  [<c011c95c>] do_softirq+0x32/0x36
[  127.758547]  [<c01043e6>] do_IRQ+0x7e/0x90
[  127.758696]  [<c010d65d>] smp_apic_timer_interrupt+0x74/0x80
[  127.758840]  [<c010c7c5>] smp_call_function_interrupt+0x3c/0x52
[  127.758978]  [<c0102f1f>] common_interrupt+0x23/0x28
[  127.759115]  [<c0100ab1>] mwait_idle_with_hints+0x3b/0x3f
[  127.759254]  [<c0100bbc>] cpu_idle+0x59/0x6e
[  127.759390]  [<c0421bcd>] start_kernel+0x2ea/0x2f2
[  127.759534]  [<c0421440>] unknown_bootoption+0x0/0x202
[  127.759672]  =======================
[  127.765948] u32 classifier
[  127.766062]     Performance counters on
[  127.766177]     input device check on 
[  127.766293]     Actions configured 
[  128.857330] WARNING: at net/sched/sch_htb.c:404 htb_safe_rb_erase()
[  128.857449]  [<f88394c5>] htb_deactivate_prios+0x135/0x18c [sch_htb]
[  128.857606]  [<f883addd>] htb_dequeue+0x468/0x6d6 [sch_htb]
[  128.857754]  [<c02bcf9b>] __qdisc_run+0x1e/0x190
[  128.857901]  [<c02b352c>] dev_queue_xmit+0x152/0x266
[  128.858048]  [<c02e80d0>] arp_send+0x4c/0x64
[  128.858191]  [<c02e76d2>] arp_xmit+0x4d/0x51
[  128.858331]  [<c02e8936>] arp_solicit+0x132/0x190
[  128.858469]  [<c02b814f>] neigh_timer_handler+0x238/0x281
[  128.858606]  [<c02b7f17>] neigh_timer_handler+0x0/0x281
[  128.858744]  [<c011f798>] run_timer_softirq+0xfa/0x15d
[  128.858887]  [<c011c8c6>] __do_softirq+0x5d/0xc1
[  128.859027]  [<c011c95c>] do_softirq+0x32/0x36
[  128.859166]  [<c010d65d>] smp_apic_timer_interrupt+0x74/0x80
[  128.859307]  [<c010c7c5>] smp_call_function_interrupt+0x3c/0x52
[  128.859449]  [<c0102fdc>] apic_timer_interrupt+0x28/0x30
[  128.859589]  [<c0100ab1>] mwait_idle_with_hints+0x3b/0x3f
[  128.859727]  [<c0100bbc>] cpu_idle+0x59/0x6e
[  128.859862]  [<c0421bcd>] start_kernel+0x2ea/0x2f2
[  128.860007]  [<c0421440>] unknown_bootoption+0x0/0x202
[  128.860144]  =======================
[  189.139227] megaraid: aborting-1187 cmd=28 <c=2 t=0 l=0>
[  189.139337] megaraid: 1187:11[255:0], abort from completed list

### System is freeze. Keyboard not work. reboot on panic not work. Reboot
manual

[   31.131000] HTB: quantum of class 10002 is big. Consider r2q change.
[   31.156000] HTB: quantum of class 10004 is big. Consider r2q change.
[   31.159000] HTB: quantum of class 10005 is big. Consider r2q change.
[   31.162000] HTB: quantum of class 10007 is big. Consider r2q change.
[   31.165000] HTB: quantum of class 10008 is big. Consider r2q change.
[   31.177000] HTB: quantum of class 10002 is big. Consider r2q change.
[   31.181000] HTB: quantum of class 10004 is big. Consider r2q change.
[   31.183000] HTB: quantum of class 10005 is big. Consider r2q change.
[   31.186000] HTB: quantum of class 10007 is big. Consider r2q change.
[   31.189000] HTB: quantum of class 10008 is big. Consider r2q change.
[   31.200000] u32 classifier
[   31.200000]     Performance counters on
[   31.200000]     input device check on 
[   31.200000]     Actions configured 
[   32.480000] WARNING: at net/sched/sch_htb.c:404 htb_safe_rb_erase()
[   32.480000]  [<f88394c5>] htb_deactivate_prios+0x135/0x18c [sch_htb]
[   32.480000]  [<f883addd>] htb_dequeue+0x468/0x6d6 [sch_htb]
[   32.480000]  [<c02bcf9b>] __qdisc_run+0x1e/0x190
[   32.480000]  [<c02b352c>] dev_queue_xmit+0x152/0x266
[   32.480000]  [<c02b7a40>] neigh_resolve_output+0x1f2/0x224
[   32.480000]  [<c02ceaee>] ip_output+0x28f/0x2bd
[   32.480000]  [<c02cbd94>] dst_output+0x0/0x7
[   32.480000]  [<c02ce48b>] ip_build_and_send_pkt+0x1da/0x1ef
[   32.480000]  [<c02cbd94>] dst_output+0x0/0x7
[   32.480000]  [<c02dfbed>] tcp_v4_send_synack+0x9f/0xf3
[   32.480000]  [<c02e140a>] tcp_v4_conn_request+0x379/0x3ae
[   32.480000]  [<c02c6913>] rt_intern_hash+0x31f/0x331
[   32.480000]  [<c02da4f5>] tcp_rcv_state_process+0x62/0xad1
[   32.480000]  [<c02e090a>] tcp_v4_do_rcv+0x2be/0x311
[   32.480000]  [<c02e2938>] tcp_v4_rcv+0x86a/0x8de
[   32.480000]  [<c02c9ec9>] ip_local_deliver+0x18b/0x232
[   32.480000]  [<c02c9608>] ip_local_deliver_finish+0x0/0x1b2
[   32.480000]  [<c02c9d05>] ip_rcv+0x484/0x4bd
[   32.480000]  [<c02b155f>] netif_receive_skb+0x2bc/0x32b
[   32.480000]  [<c023ca05>] e1000_clean_rx_irq+0x375/0x444
[   32.480000]  [<c023c690>] e1000_clean_rx_irq+0x0/0x444
[   32.480000]  [<c023baa9>] e1000_clean+0x7a/0x249
[   32.480000]  [<c02b32e6>] net_rx_action+0x91/0x185
[   32.480000]  [<c011c8c6>] __do_softirq+0x5d/0xc1
[   32.480000]  [<c011c95c>] do_softirq+0x32/0x36
[   32.480000]  [<c01043e6>] do_IRQ+0x7e/0x90
[   32.480000]  [<c010d65d>] smp_apic_timer_interrupt+0x74/0x80
[   32.480000]  [<c010c7c5>] smp_call_function_interrupt+0x3c/0x52
[   32.480000]  [<c0102f1f>] common_interrupt+0x23/0x28
[   32.480000]  [<c0100ab1>] mwait_idle_with_hints+0x3b/0x3f
[   32.480000]  [<c0100bbc>] cpu_idle+0x59/0x6e
[   32.480000]  [<c0421bcd>] start_kernel+0x2ea/0x2f2
[   32.480000]  [<c0421440>] unknown_bootoption+0x0/0x202
[   32.480000]  =======================
[   76.104000] input: AT Translated Set 2 keyboard as /class/input/input2

### System is freeze. Keyboard not work. reboot on panic not work. Reboot
manual

--------------030801050200020809080400--
