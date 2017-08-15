From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: 100% CPU load when generating traffic to destination network that
 nexthop is not reachable
Date: Wed, 16 Aug 2017 00:00:25 +0200
Message-ID: <fe7713c9-45e9-f78e-cf5c-d9804344dbc8@itcare.pl>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
 <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
 <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>
 <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <dff2938a-7531-dafb-4d70-98c382c96a86@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:49298 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751095AbdHOWBa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 18:01:30 -0400
In-Reply-To: <dff2938a-7531-dafb-4d70-98c382c96a86@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also after adding this patch:

[ 3843.036247] NEIGH: BUG, double timer add, state is 1
[ 3843.036253] CPU: 24 PID: 0 Comm: swapper/24 Not tainted 
4.13.0-rc5-next-20170815 #2
[ 3843.036254] Call Trace:
[ 3843.036255]  <IRQ>
[ 3843.036263]  dump_stack+0x4d/0x63
[ 3843.036267]  neigh_add_timer+0x36/0x39
[ 3843.036269]  __neigh_event_send+0x89/0x1bd
[ 3843.036270]  neigh_event_send+0x2b/0x2d
[ 3843.036272]  neigh_resolve_output+0x18/0x122
[ 3843.036276]  ip_finish_output2+0x24b/0x28f
[ 3843.036277]  ip_finish_output+0x101/0x10d
[ 3843.036279]  ip_output+0x56/0xa7
[ 3843.036280]  ? ip_route_input_rcu+0x4dd/0x7d3
[ 3843.036282]  ip_forward_finish+0x53/0x58
[ 3843.036283]  ip_forward+0x2b8/0x309
[ 3843.036285]  ? ip_frag_mem+0x1e/0x1e
[ 3843.036286]  ip_rcv_finish+0x27c/0x287
[ 3843.036287]  ip_rcv+0x2b0/0x2fd
[ 3843.036290]  __netif_receive_skb_core+0x316/0x4ab
[ 3843.036292]  ? __netif_receive_skb_core+0x4a1/0x4ab
[ 3843.036293]  __netif_receive_skb+0x18/0x57
[ 3843.036294]  ? __netif_receive_skb+0x18/0x57
[ 3843.036296]  netif_receive_skb_internal+0x4b/0xa1
[ 3843.036297]  napi_gro_receive+0x75/0xcc
[ 3843.036315]  mlx5e_handle_rx_cqe+0x3d3/0x48f [mlx5_core]
[ 3843.036319]  ? tick_program_event+0x5d/0x64
[ 3843.036327]  mlx5e_poll_rx_cq+0x139/0x166 [mlx5_core]
[ 3843.036334]  mlx5e_napi_poll+0x87/0x26d [mlx5_core]
[ 3843.036336]  net_rx_action+0xd3/0x22d
[ 3843.036341]  __do_softirq+0xe4/0x23a
[ 3843.036346]  irq_exit+0x4d/0x5b
[ 3843.036347]  do_IRQ+0x96/0xae
[ 3843.036349]  common_interrupt+0x90/0x90
[ 3843.036350]  </IRQ>
[ 3843.036353] RIP: 0010:cpuidle_enter_state+0x134/0x189
[ 3843.036354] RSP: 0018:ffffc900033cfea0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffffb6
[ 3843.036356] RAX: 0000037ec6cf262f RBX: 0000000000000001 RCX: 
000000000000001f
[ 3843.036356] RDX: 0000000000000000 RSI: 0000000000000018 RDI: 
0000000000000000
[ 3843.036357] RBP: ffffc900033cfed0 R08: 000000000000000c R09: 
00000000000001a5
[ 3843.036358] R10: ffffc900033cfe70 R11: ffff88087f898c50 R12: 
ffff88046c3d9a00
[ 3843.036359] R13: 0000037ec6cf262f R14: 0000000000000001 R15: 
0000037ec6ce8825
[ 3843.036361]  cpuidle_enter+0x12/0x14
[ 3843.036363]  do_idle+0x113/0x16b
[ 3843.036364]  cpu_startup_entry+0x1a/0x1c
[ 3843.036367]  start_secondary+0xd0/0xd3
[ 3843.036370]  secondary_startup_64+0xa5/0xa5
[ 3843.037807] NEIGH: BUG, double timer add, state is 1
[ 3843.037811] CPU: 9 PID: 0 Comm: swapper/9 Not tainted 
4.13.0-rc5-next-20170815 #2
[ 3843.037812] Call Trace:
[ 3843.037813]  <IRQ>
[ 3843.037819]  dump_stack+0x4d/0x63
[ 3843.037822]  neigh_add_timer+0x36/0x39
[ 3843.037824]  __neigh_event_send+0x89/0x1bd
[ 3843.037825]  neigh_event_send+0x2b/0x2d
[ 3843.037826]  neigh_resolve_output+0x18/0x122
[ 3843.037829]  ip_finish_output2+0x24b/0x28f
[ 3843.037831]  ip_finish_output+0x101/0x10d
[ 3843.037832]  ip_output+0x56/0xa7
[ 3843.037834]  ? ip_route_input_rcu+0x4dd/0x7d3
[ 3843.037836]  ip_forward_finish+0x53/0x58
[ 3843.037837]  ip_forward+0x2b8/0x309
[ 3843.037838]  ? ip_frag_mem+0x1e/0x1e
[ 3843.037840]  ip_rcv_finish+0x27c/0x287
[ 3843.037841]  ip_rcv+0x2b0/0x2fd
[ 3843.037843]  __netif_receive_skb_core+0x316/0x4ab
[ 3843.037845]  __netif_receive_skb+0x18/0x57
[ 3843.037846]  ? __netif_receive_skb+0x18/0x57
[ 3843.037848]  netif_receive_skb_internal+0x4b/0xa1
[ 3843.037849]  napi_gro_receive+0x75/0xcc
[ 3843.037863]  mlx5e_handle_rx_cqe+0x3d3/0x48f [mlx5_core]
[ 3843.037871]  mlx5e_poll_rx_cq+0x139/0x166 [mlx5_core]
[ 3843.037879]  mlx5e_napi_poll+0x87/0x26d [mlx5_core]
[ 3843.037881]  net_rx_action+0xd3/0x22d
[ 3843.037885]  __do_softirq+0xe4/0x23a
[ 3843.037889]  irq_exit+0x4d/0x5b
[ 3843.037890]  do_IRQ+0x96/0xae
[ 3843.037892]  common_interrupt+0x90/0x90
[ 3843.037893]  </IRQ>
[ 3843.037895] RIP: 0010:cpuidle_enter_state+0x134/0x189
[ 3843.037896] RSP: 0018:ffffc90003357ea0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff98
[ 3843.037898] RAX: 0000037ec6cffd61 RBX: 0000000000000002 RCX: 
000000000000001f
[ 3843.037899] RDX: 0000000000000000 RSI: 0000000000000009 RDI: 
0000000000000000
[ 3843.037899] RBP: ffffc90003357ed0 R08: 00000000ffffffff R09: 
0000000000000003
[ 3843.037900] R10: ffffc90003357e70 R11: ffff88046fc58c50 R12: 
ffff88046c3b0400
[ 3843.037901] R13: 0000037ec6cffd61 R14: 0000000000000002 R15: 
0000037ec6cf68de
[ 3843.037903]  cpuidle_enter+0x12/0x14
[ 3843.037905]  do_idle+0x113/0x16b
[ 3843.037907]  cpu_startup_entry+0x1a/0x1c
[ 3843.037909]  start_secondary+0xd0/0xd3
[ 3843.037912]  secondary_startup_64+0xa5/0xa5
[ 3855.324247] NEIGH: BUG, double timer add, state is 1
[ 3855.324251] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 
4.13.0-rc5-next-20170815 #2
[ 3855.324252] Call Trace:
[ 3855.324254]  <IRQ>
[ 3855.324259]  dump_stack+0x4d/0x63
[ 3855.324262]  neigh_add_timer+0x36/0x39
[ 3855.324264]  __neigh_event_send+0x89/0x1bd
[ 3855.324265]  neigh_event_send+0x2b/0x2d
[ 3855.324267]  neigh_resolve_output+0x18/0x122
[ 3855.324269]  ip_finish_output2+0x24b/0x28f
[ 3855.324271]  ip_finish_output+0x101/0x10d
[ 3855.324272]  ip_output+0x56/0xa7
[ 3855.324274]  ? ip_route_input_rcu+0x4dd/0x7d3
[ 3855.324276]  ip_forward_finish+0x53/0x58
[ 3855.324277]  ip_forward+0x2b8/0x309
[ 3855.324279]  ? ip_frag_mem+0x1e/0x1e
[ 3855.324280]  ip_rcv_finish+0x27c/0x287
[ 3855.324281]  ip_rcv+0x2b0/0x2fd
[ 3855.324284]  __netif_receive_skb_core+0x316/0x4ab
[ 3855.324285]  __netif_receive_skb+0x18/0x57
[ 3855.324286]  ? __netif_receive_skb+0x18/0x57
[ 3855.324288]  netif_receive_skb_internal+0x4b/0xa1
[ 3855.324289]  napi_gro_receive+0x75/0xcc
[ 3855.324304]  mlx5e_handle_rx_cqe+0x3d3/0x48f [mlx5_core]
[ 3855.324312]  mlx5e_poll_rx_cq+0x139/0x166 [mlx5_core]
[ 3855.324320]  mlx5e_napi_poll+0x87/0x26d [mlx5_core]
[ 3855.324322]  net_rx_action+0xd3/0x22d
[ 3855.324325]  __do_softirq+0xe4/0x23a
[ 3855.324329]  irq_exit+0x4d/0x5b
[ 3855.324330]  do_IRQ+0x96/0xae
[ 3855.324332]  common_interrupt+0x90/0x90
[ 3855.324332]  </IRQ>
[ 3855.324335] RIP: 0010:cpuidle_enter_state+0x134/0x189
[ 3855.324336] RSP: 0018:ffffc90003347ea0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffffb8
[ 3855.324337] RAX: 00000381a339f6dc RBX: 0000000000000002 RCX: 
000000000000001f
[ 3855.324338] RDX: 0000000000000000 RSI: 0000000000000007 RDI: 
0000000000000000
[ 3855.324339] RBP: ffffc90003347ed0 R08: 0000000000000007 R09: 
0000000000000003
[ 3855.324339] R10: ffffc90003347e70 R11: ffff88046fbd8c50 R12: 
ffff88046c398a00
[ 3855.324340] R13: 00000381a339f6dc R14: 0000000000000002 R15: 
00000381a3396ac5
[ 3855.324342]  cpuidle_enter+0x12/0x14
[ 3855.324344]  do_idle+0x113/0x16b
[ 3855.324345]  cpu_startup_entry+0x1a/0x1c
[ 3855.324347]  start_secondary+0xd0/0xd3
[ 3855.324350]  secondary_startup_64+0xa5/0xa5
[ 3855.326261] NEIGH: BUG, double timer add, state is 1
[ 3855.326265] CPU: 45 PID: 0 Comm: swapper/45 Not tainted 
4.13.0-rc5-next-20170815 #2
[ 3855.326267] Call Trace:
[ 3855.326268]  <IRQ>
[ 3855.326275]  dump_stack+0x4d/0x63
[ 3855.326279]  neigh_add_timer+0x36/0x39
[ 3855.326281]  __neigh_event_send+0x89/0x1bd
[ 3855.326282]  neigh_event_send+0x2b/0x2d
[ 3855.326284]  neigh_resolve_output+0x18/0x122
[ 3855.326287]  ip_finish_output2+0x24b/0x28f
[ 3855.326289]  ip_finish_output+0x101/0x10d
[ 3855.326290]  ip_output+0x56/0xa7
[ 3855.326292]  ? ip_route_input_rcu+0x4dd/0x7d3
[ 3855.326294]  ip_forward_finish+0x53/0x58
[ 3855.326295]  ip_forward+0x2b8/0x309
[ 3855.326296]  ? ip_frag_mem+0x1e/0x1e
[ 3855.326297]  ip_rcv_finish+0x27c/0x287
[ 3855.326299]  ip_rcv+0x2b0/0x2fd
[ 3855.326302]  __netif_receive_skb_core+0x316/0x4ab
[ 3855.326303]  __netif_receive_skb+0x18/0x57
[ 3855.326304]  ? __netif_receive_skb+0x18/0x57
[ 3855.326306]  netif_receive_skb_internal+0x4b/0xa1
[ 3855.326307]  napi_gro_receive+0x75/0xcc
[ 3855.326323]  mlx5e_handle_rx_cqe+0x3d3/0x48f [mlx5_core]
[ 3855.326328]  ? handle_irq_event+0x35/0x46
[ 3855.326336]  mlx5e_poll_rx_cq+0x139/0x166 [mlx5_core]
[ 3855.326344]  mlx5e_napi_poll+0x87/0x26d [mlx5_core]
[ 3855.326345]  net_rx_action+0xd3/0x22d
[ 3855.326349]  __do_softirq+0xe4/0x23a
[ 3855.326353]  ? tick_program_event+0x5d/0x64
[ 3855.326356]  irq_exit+0x4d/0x5b
[ 3855.326358]  smp_apic_timer_interrupt+0x29/0x34
[ 3855.326360]  apic_timer_interrupt+0x90/0xa0
[ 3855.326360]  </IRQ>
[ 3855.326363] RIP: 0010:cpuidle_enter_state+0x134/0x189
[ 3855.326364] RSP: 0018:ffffc90003477ea0 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff10
[ 3855.326366] RAX: 00000381a33b2cd6 RBX: 0000000000000002 RCX: 
000000000000001f
[ 3855.326366] RDX: 0000000000000000 RSI: 000000000000002d RDI: 
0000000000000000
[ 3855.326367] RBP: ffffc90003477ed0 R08: 00000000ffffffe2 R09: 
0000000000000252
[ 3855.326368] R10: ffffc90003477e70 R11: ffff88087fa58c50 R12: 
ffff88046b918200
[ 3855.326368] R13: 00000381a33b2cd6 R14: 0000000000000002 R15: 
00000381a33a9c4a
[ 3855.326371]  cpuidle_enter+0x12/0x14
[ 3855.326372]  do_idle+0x113/0x16b
[ 3855.326373]  cpu_startup_entry+0x1a/0x1c
[ 3855.326376]  start_secondary+0xd0/0xd3
[ 3855.326379]  secondary_startup_64+0xa5/0xa5



W dniu 2017-08-15 o 22:53, Paweł Staszewski pisze:
> Hi
>
>
> Patch applied but no change still 100% CPU
>
> perf below:
>
>      1.99%     0.00%  ksoftirqd/1      [kernel.vmlinux] [k] run_ksoftirqd
>             |
>             ---run_ksoftirqd
>                |
>                 --1.99%--__softirqentry_text_start
>                           |
>                            --1.99%--net_rx_action
>                                      |
>                                       --1.98%--mlx5e_napi_poll
>                                                 |
> --1.98%--mlx5e_poll_rx_cq
>                                                            |
> --1.98%--mlx5e_handle_rx_cqe
>                                                                       |
> --1.96%--napi_gro_receive
> |
> --1.96%--netif_receive_skb_internal
> |
> --1.96%--__netif_receive_skb
> |
> --1.96%--__netif_receive_skb_core
> |
> --1.95%--ip_rcv
> |
> --1.95%--ip_rcv_finish
> |
> --1.94%--ip_forward
> |
> --1.94%--ip_forward_finish
> |
> --1.94%--ip_output
> |
> --1.94%--ip_finish_output
> |
> --1.94%--ip_finish_output2
> |
> --1.90%--neigh_resolve_output
> |
> --1.90%--neigh_event_send
> |
> --1.90%--__neigh_event_send
> |
> --1.87%--_raw_write_lock_bh
> queued_write_lock
> queued_write_lock_slowpath
> |
> --1.84%--queued_spin_lock_slowpath
>
>
> W dniu 2017-08-15 o 21:11, Eric Dumazet pisze:
>> On Tue, 2017-08-15 at 19:42 +0200, Paweł Staszewski wrote:
>>> # To display the perf.data header info, please use
>>> --header/--header-only options.
>>> #
>>> #
>>> # Total Lost Samples: 0
>>> #
>>> # Samples: 2M of event 'cycles'
>>> # Event count (approx.): 1585571545969
>>> #
>>> # Children      Self  Command         Shared Object Symbol
>>> # ........  ........  ..............  ....................
>>> ..............................................
>>> #
>>>        1.82%     0.00%  ksoftirqd/43    [kernel.vmlinux] [k]
>>> __softirqentry_text_start
>>>               |
>>>                --1.82%--__softirqentry_text_start
>>>                          |
>>>                           --1.82%--net_rx_action
>>>                                     |
>>>                                      --1.82%--mlx5e_napi_poll
>>>                                                |
>>> --1.81%--mlx5e_poll_rx_cq
>>>                                                           |
>>> --1.81%--mlx5e_handle_rx_cqe
>>>                                                                      |
>>> --1.79%--napi_gro_receive
>>> |
>>> --1.78%--netif_receive_skb_internal
>>> |
>>> --1.78%--__netif_receive_skb
>>> |
>>> --1.78%--__netif_receive_skb_core
>>> |
>>> --1.78%--ip_rcv
>>> |
>>> --1.78%--ip_rcv_finish
>>> |
>>> --1.76%--ip_forward
>>> |
>>> --1.76%--ip_forward_finish
>>> |
>>> --1.76%--ip_output
>>> |
>>> --1.76%--ip_finish_output
>>> |
>>> --1.76%--ip_finish_output2
>>> |
>>> --1.73%--neigh_resolve_output
>>> |
>>> --1.73%--neigh_event_send
>>> |
>>> --1.73%--__neigh_event_send
>>> |
>>> --1.70%--_raw_write_lock_bh
>>> queued_write_lock
>>> queued_write_lock_slowpath
>>> |
>>> --1.67%--queued_spin_lock_slowpath
>>>
>>>
>> Please try this :
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 
>> 16a1a4c4eb57fa1147f230916e2e62e18ef89562..95e0d7702029b583de8229e3c3eb923f6395b072 
>> 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -991,14 +991,18 @@ static void neigh_timer_handler(unsigned long arg)
>>     int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>>   {
>> -    int rc;
>>       bool immediate_probe = false;
>> +    int rc;
>> +
>> +    /* We _should_ test this under write_lock_bh(&neigh->lock),
>> +     * but this is too costly.
>> +     */
>> +    if (READ_ONCE(neigh->nud_state) & (NUD_CONNECTED | NUD_DELAY | 
>> NUD_PROBE))
>> +        return 0;
>>         write_lock_bh(&neigh->lock);
>>         rc = 0;
>> -    if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
>> -        goto out_unlock_bh;
>>       if (neigh->dead)
>>           goto out_dead;
>>
>>
>>
>
>
