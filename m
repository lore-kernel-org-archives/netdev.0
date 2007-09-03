From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8971] New: htb class delete causes kernelpanic
 and other htb bugs.
Date: Mon, 3 Sep 2007 01:34:49 -0700
Message-ID: <20070903013449.eae1a9f8.akpm@linux-foundation.org>
References: <bug-8971-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, lavon@bigtelecom.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59346 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791AbXICIes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 04:34:48 -0400
In-Reply-To: <bug-8971-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon,  3 Sep 2007 00:29:48 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=8971
> 
>            Summary: htb class delete causes kernelpanic and other htb bugs.
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.18.* - 2.6.23-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@osdl.org
>         ReportedBy: slavon@bigtelecom.ru
> 
> 
> 1. sometime get kernel panic on "htb class delete"
> 
> 3931.002707] BUG: unable to handle kernel NULL pointer dereference at virtual
> address 00000008
> [ 3931.002846]  printing eip:
> [ 3931.002906] c01c8973
> [ 3931.002967] *pde = 00000000
> [ 3931.003031] Oops: 0000 [#1]
> [ 3931.003093] SMP
> [ 3931.003160] Modules linked in: cls_u32 sch_sfq sch_htb netconsole xt_tcpudp
> iptable_filter ip_tables x_tables i2c_i801 i2c_core
> [ 3931.003327] CPU:    2
> [ 3931.003327] EIP:    0060:[<c01c8973>]    Not tainted VLI
> [ 3931.003328] EFLAGS: 00010246   (2.6.23-rc4-testing #1)
> [ 3931.003526] EIP is at rb_insert_color+0x13/0xad
> [ 3931.003594] eax: 00000000   ebx: e9570324   ecx: e9570324   edx: f6deac48
> [ 3931.003663] esi: 00000000   edi: ef5c4124   ebp: f6dea8a0   esp: e25f5d6c
> [ 3931.003731] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> [ 3931.003796] Process sh (pid: 6146, ti=e25f4000 task=c268b290
> task.ti=e25f4000)
> [ 3931.003866] Stack: f6deac48 00000569 00000000 ef5c4000 f6dea8a0 f8862a9d
> f881c5db e1fda780
> [ 3931.004016]        00000003 f6db6dc0 f6deac48 f6dea800 00000000 00000000
> dfc3e9b2 00000000
> [ 3931.004161]        e25f5dd8 00000000 c02a774b 00000002 e25f5e70 f6dea930
> f6dea930 00000000
> [ 3931.004307] Call Trace:
> [ 3931.004434]  [<f8862a9d>] htb_dequeue+0x195/0x6d2 [sch_htb]
> [ 3931.004510]  [<f881c5db>] ipt_do_table+0x41f/0x47c [ip_tables]
> [ 3931.004584]  [<c02a774b>] tc_classify+0x17/0x7c
> [ 3931.004658]  [<f8861925>] htb_activate_prios+0x9b/0xa5 [sch_htb]
> [ 3931.004730]  [<c02a71af>] __qdisc_run+0x2a/0x16b
> [ 3931.004798]  [<c029cfc1>] dev_queue_xmit+0x18b/0x2a6
> [ 3931.004874]  [<c02b94e3>] ip_output+0x281/0x2ba
> [ 3931.004947]  [<c02b571c>] ip_forward_finish+0x0/0x2e
> [ 3931.005012]  [<c02b59b5>] ip_forward+0x26b/0x2c6
> [ 3931.005081]  [<c02b571c>] ip_forward_finish+0x0/0x2e
> [ 3931.005150]  [<c02b4729>] ip_rcv+0x484/0x4bd
> [ 3931.005216]  [<c013dcc5>] file_read_actor+0x0/0xdb
> [ 3931.005293]  [<c029ab9c>] netif_receive_skb+0x2cd/0x340
> [ 3931.005362]  [<c0234ef1>] e1000_clean_rx_irq+0x379/0x448
> [ 3931.005437]  [<c0234b78>] e1000_clean_rx_irq+0x0/0x448
> [ 3931.005506]  [<c0233f8f>] e1000_clean+0x7a/0x249
> [ 3931.005574]  [<c029ccad>] net_rx_action+0x91/0x17f
> [ 3931.005642]  [<c01225e2>] __do_softirq+0x5d/0xc1
> [ 3931.005714]  [<c0122678>] do_softirq+0x32/0x36
> [ 3931.005779]  [<c010488a>] do_IRQ+0x7e/0x90
> [ 3931.005849]  [<c01032eb>] common_interrupt+0x23/0x28
> [ 3931.005923]  =======================
> [ 3931.005986] Code: 56 04 eb 07 89 56 08 eb 02 89 17 8b 03 83 e0 03 09 d0 89
> 03 5b 5e 5f c3 55 57 89 c7 56 53 83 ec 04 89 14 24 eb 7e 89 c6 83 e6 fc <8b> 56
> 08 39 d3 75 34 8b 56 04 85 d2 74 06 8b 02 a8 01 74 31 8b
> [ 3931.006386] EIP: [<c01c8973>] rb_insert_color+0x13/0xad SS:ESP 0068:e25f5d6c
> [ 3931.006757] Kernel panic - not syncing: Fatal exception in interrupt
> [ 3931.006863] Rebooting in 3 seconds.. 
> 
> its becouse 
> 
> (gdb) l *0xc01c8973
> 0xc01c8973 is in rb_insert_color (lib/rbtree.c:80).
> 75
> 76              while ((parent = rb_parent(node)) && rb_is_red(parent))
> 77              {
> 78                      gparent = rb_parent(parent);
> 79
> 80                      if (parent == gparent->rb_left)
> 81                      {
> 82                              {
> 83                                      register struct rb_node *uncle =
> gparent->rb_right;
> 84                                      if (uncle && rb_is_red(uncle)) 
> 
> gparent == NULL
> 
> 2. HTB levels wrong calculate!
> Try run
> tc qdisc add dev eth1 root handle 1 htb default 7
>     tc class add dev eth1 parent 1: classid 1:2 htb rate 400mbit ceil 400mbit
> burst 50kb cburst 50kb prio 0
>         # max prio ICMP - NOT USED
>         tc class add dev eth1 parent 1:2 classid 1:3 htb rate 10mbit ceil
> 10mbit burst 1250b cburst 1250b prio 0
>         tc qdisc add dev eth1 parent 1:3 handle 3 sfq perturb 10
>         # corp - NOT USED
>         tc class add dev eth1 parent 1:2 classid 1:4 htb rate 50mbit ceil
> 50mbit burst 6250b cburst 6250b prio 1
>         tc qdisc add dev eth1 parent 1:4 handle 4 sfq perturb 10
>         # general
>         tc class add dev eth1 parent 1:2 classid 1:5 htb rate 340mbit ceil
> 400mbit burst 42500b cburst 50kb prio 2
>             # LIDER
>             tc class add dev eth1 parent 1:5 classid 1:6 htb rate 9mbit ceil
> 9mbit burst 1125b cburst 1125b prio 1
>                 #....
> 
>             # GENERAL
>             tc class add dev eth1 parent 1:5 classid 1:7 htb rate 100mbit ceil
> 400mbit burst 12500b cburst 50kb prio 2
>             tc qdisc add dev eth1 parent 1:7 handle 7 sfq perturb 10
> 
>             # limiting speed
>             tc class add dev eth1 parent 1:5 classid 1:8 htb rate 231mbit ceil
> 400mbit burst 23100b cburst 50kb prio 1
>                 #....
> 
> 
> and see levels
> tc -d class show dev eth0
> 
> 3. "tc -d class show dev eth0 | grep -v leaf" ask many rules without leaf, but
> QDISC for this classes is created. (run create_nodes.sh; sh tc_last_rules)
> 

