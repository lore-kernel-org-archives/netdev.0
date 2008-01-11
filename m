From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: HTB classify perfomance
Date: Fri, 11 Jan 2008 11:53:19 +0300
Message-ID: <47872E7F.6090300@bigtelecom.ru>
References: <47872845.8000702@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:41872 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694AbYAKIx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 03:53:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 3BA3EA6C23F
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 11:53:26 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lfxc08knt3oQ for <netdev@vger.kernel.org>;
	Fri, 11 Jan 2008 11:53:19 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 8805DA6C124
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 11:53:19 +0300 (MSK)
In-Reply-To: <47872845.8000702@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New info. Wait some time and reset oprifile statistic (i think info 
abount ipt_unregister_table its get what run some script... ).
That clear info after add FILTER:

First PC
CPU: P4 / Xeon, speed 3409.96 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
stopped) with a unit mask of 0x01 (mandatory) count 100000
samples  %        app name                 symbol name
1158171  19.1292  vmlinux                  ipt_do_table
722416   11.9319  vmlinux                  e1000_intr
627406   10.3627  vmlinux                  u32_classify
565286    9.3367  vmlinux                  e1000_irq_enable
269309    4.4481  vmlinux                  htb_dequeue
191016    3.1550  vmlinux                  ip_route_input
187127    3.0907  vmlinux                  sfq_dequeue
172775    2.8537  vmlinux                  e1000_clean_tx_irq
154654    2.5544  vmlinux                  e1000_clean_rx_irq
146926    2.4267  vmlinux                  sfq_enqueue
116782    1.9289  vmlinux                  htb_add_to_wait_tree
79398     1.3114  vmlinux                  rb_erase
74411     1.2290  vmlinux                  e1000_xmit_frame
65451     1.0810  vmlinux                  kfree
59966     0.9904  vmlinux                  irq_entries_start
59893     0.9892  vmlinux                  eth_type_trans
55510     0.9168  vmlinux                  dev_queue_xmit
52688     0.8702  vmlinux                  e1000_alloc_rx_buffers





> Hello all.
> I N days try to tune system for best performance and see strange thing.
>
> Have N htb classes
> root class is HTB. param: default 7 (if not classify - go to 1:7)
>
> filters classify only mached ip. others go to HTB DEFAULT rule.
>
> run oprofile:
> First pc (htb and iptables compile in kernel):
> CPU: P4 / Xeon, speed 3409.94 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        app name                 symbol name
> 743501   47.6081  vmlinux                  htb_classify
> 208718   13.3647  vmlinux                  ipt_do_table
> 94473     6.0493  vmlinux                  u32_classify
> 43088     2.7590  vmlinux                  e1000_intr
> 35086     2.2466  vmlinux                  e1000_clean_tx_irq
> 34925     2.2363  vmlinux                  ip_route_input
> 33972     2.1753  vmlinux                  e1000_irq_enable
> 33788     2.1635  vmlinux                  htb_dequeue
> 29197     1.8696  vmlinux                  e1000_clean_rx_irq
> 20177     1.2920  vmlinux                  sfq_dequeue
> 17825     1.1414  vmlinux                  sfq_enqueue
> 15135     0.9691  vmlinux                  e1000_xmit_frame
> 15123     0.9684  vmlinux                  eth_type_trans
> 13081     0.8376  vmlinux                  kfree
> 12153     0.7782  vmlinux                  dev_queue_xmit
>
> Second PC (htb and iptables is modules)
> CPU: P4 / Xeon with 2 hyper-threads, speed 3192.35 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        app name                 symbol name
> 102108   30.7351  sch_htb                  (no symbols)
> 21559     6.4894  vmlinux                  e1000_intr
> 17428     5.2459  cls_u32                  (no symbols)
> 13887     4.1801  ip_tables                (no symbols)
> 11984     3.6072  sch_sfq                  (no symbols)
> 11785     3.5473  vmlinux                  e1000_irq_enable
> 9684      2.9149  vmlinux                  mwait_idle_with_hints
> 9227      2.7774  vmlinux                  e1000_clean_rx_irq
> 8686      2.6145  vmlinux                  e1000_clean_tx_irq
> 6747      2.0309  vmlinux                  ip_route_input
> 6533      1.9665  vmlinux                  irq_entries_start
> 6419      1.9322  vmlinux                  e1000_xmit_frame
> 5605      1.6871  vmlinux                  dev_queue_xmit
> 4030      1.2131  vmlinux                  __kfree_skb
> 3997      1.2031  vmlinux                  __qdisc_run
> 3931      1.1833  vmlinux                  e1000_clean
> 3565      1.0731  vmlinux                  net_rx_action
> 3518      1.0589  vmlinux                  ip_rcv
> 3377      1.0165  vmlinux                  getnstimeofday
> 3215      0.9677  vmlinux                  rb_erase
> 2973      0.8949  vmlinux                  eth_type_trans
> 2707      0.8148  vmlinux                  ip_output
> 2586      0.7784  vmlinux                  handle_fasteoi_irq
>
> Hmm.. strange... look to code htb_classify i see only one place where 
> it may get many CPU.
>
> ok... try to add to the end of tc batch file..
> filter add dev eth1 protocol ip parent 1:0 prio 5 u32 ht 800:: match 
> ip protocol 1 0x00 flowid 1:7
> filter add dev eth0 protocol ip parent 1:0 prio 5 u32 ht 800:: match 
> ip protocol 1 0x00 flowid 1:7
> (offtopic... strange... i not found that i can add filter without any 
> match)
>
> Wow!
> CPU: P4 / Xeon, speed 3409.94 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        app name                 symbol name
> 153128   20.9497  vmlinux                  ipt_unregister_table
> 121569   16.6321  vmlinux                  e1000_request_irq
> 60727     8.3082  vmlinux                  e1000_update_itr
> 47241     6.4631  vmlinux                  u32_delete
> 25836     3.5347  vmlinux                  htb_dequeue
> 18304     2.5042  vmlinux                  ipt_do_table
> 15980     2.1862  vmlinux                  mwait_idle_with_hints
> 15977     2.1858  vmlinux                  irq_entries_start
> 13337     1.8247  vmlinux                  htb_classify
> 12512     1.7118  vmlinux                  __ip_route_output_key
> 8821      1.2068  vmlinux                  sfq_init
> 8495      1.1622  vmlinux                  e1000_clean_rx_irq
> 8408      1.1503  vmlinux                  htb_enqueue
> 8018      1.0970  vmlinux                  e1000_xmit_frame
> 7867      1.0763  vmlinux                  e1000_clean_tx_ring
> 6336      0.8668  vmlinux                  htb_delete
> 5828      0.7973  vmlinux                  ___pskb_trim
> 5781      0.7909  vmlinux                  s_start
> 5234      0.7161  vmlinux                  e1000_clean_rx_irq_ps
> 4504      0.6162  vmlinux                  cache_alloc_refill
> 4133      0.5654  vmlinux                  radix_tree_delete
>
> Second PC
> CPU: P4 / Xeon with 2 hyper-threads, speed 3192.35 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        app name                 symbol name
> 37747    13.3616  sch_htb                  (no symbols)
> 23606     8.3560  vmlinux                  e1000_intr
> 18158     6.4275  cls_u32                  (no symbols)
> 14726     5.2127  ip_tables                (no symbols)
> 13137     4.6502  vmlinux                  e1000_irq_enable
> 12307     4.3564  sch_sfq                  (no symbols)
> 9974      3.5306  vmlinux                  mwait_idle_with_hints
> 9855      3.4884  vmlinux                  e1000_clean_rx_irq
> 9077      3.2131  vmlinux                  e1000_clean_tx_irq
> 7293      2.5816  vmlinux                  irq_entries_start
> 6956      2.4623  vmlinux                  ip_route_input
> 6652      2.3547  vmlinux                  e1000_xmit_frame
> 6202      2.1954  vmlinux                  dev_queue_xmit
> 4403      1.5586  vmlinux                  __kfree_skb
> 4230      1.4973  vmlinux                  net_rx_action
> 4224      1.4952  vmlinux                  e1000_clean
> 4042      1.4308  vmlinux                  __qdisc_run
> 3513      1.2435  vmlinux                  ip_rcv
> 3509      1.2421  vmlinux                  getnstimeofday
> 3377      1.1954  vmlinux                  rb_erase
> 3191      1.1295  vmlinux                  eth_type_trans
> 2953      1.0453  vmlinux                  handle_fasteoi_irq
> 2830      1.0018  vmlinux                  ip_output
>
>
> Looks great!
> I hope i found interesting place for optimization.
>
> Thanks.
> Slavon.
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

