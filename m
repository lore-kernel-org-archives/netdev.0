From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 16:13:59 +0300
Message-ID: <200808161613.59948.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808161524.30272.denys@visp.net.lb> <20080816123453.GB7519@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:54876 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbYHPNPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 09:15:09 -0400
In-Reply-To: <20080816123453.GB7519@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 16 August 2008, Jarek Poplawski wrote:
> On Sat, Aug 16, 2008 at 03:24:30PM +0300, Denys Fedoryshchenko wrote:
> > Do you want me to reverse previous one?
>
> Yes, please. I forgot to mention this.
>
> Jarek P.

Here is what i got:
Aug 16 16:07:33 192.168.20.66 kernel: [   61.930066] ------------[ cut here ]------------
Aug 16 16:07:33 192.168.20.66 kernel: [   61.930066] WARNING: at include/linux/skbuff.h:692 qdisc_requeue+0x56/0x6e()
Aug 16 16:07:33 192.168.20.66 kernel: [   61.930066] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:07:33 192.168.20.66 kernel: [   61.934080] Pid: 6317, comm: modprobe Not tainted 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:07:33 192.168.20.66 kernel: [   61.934080]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:07:33 192.168.20.66 kernel: [   61.934080]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:07:33 192.168.20.66 kernel: [   61.934080]  [<c02bdc12>] ? _spin_unlock+0x1d/0x20
Aug 16 16:07:33 192.168.20.66 kernel: [   61.935017]  [<c013d91c>] ? mark_held_locks+0x53/0x6a
Aug 16 16:07:33 192.168.20.66 kernel: [   61.935069]  [<c013d91c>] ? mark_held_locks+0x53/0x6a
Aug 16 16:07:33 192.168.20.66 kernel: [   61.935069]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:07:33 192.168.20.66 kernel: [   61.935069]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:07:33 192.168.20.66 kernel: [   61.935069]  [<c013da7d>] ? trace_hardirqs_on_caller+0xcb/0x102
Aug 16 16:07:33 192.168.20.66 kernel: [   61.935069]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:07:33 192.168.20.66 kernel: [   61.936074]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:07:33 192.168.20.66 kernel: [   61.936074]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:07:33 192.168.20.66 kernel: [   61.936074]  [<c0272dbd>] qdisc_requeue+0x56/0x6e
Aug 16 16:07:33 192.168.20.66 kernel: [   61.936074]  [<f8a10689>] tbf_dequeue+0x166/0x19b [sch_tbf]
Aug 16 16:07:33 192.168.20.66 kernel: [   61.936074]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937008]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937066]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937066]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937066]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937066]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937066]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:07:33 192.168.20.66 kernel: [   61.937066]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:07:33 192.168.20.66 kernel: [   61.938072]  [<c01400d8>] ? lockdep_stats_show+0x2e0/0x357
Aug 16 16:07:33 192.168.20.66 kernel: [   61.938123]  [<c01dd719>] ? __copy_to_user_ll+0x50/0xd7
Aug 16 16:07:33 192.168.20.66 kernel: [   61.938123]  [<c014c03d>] file_read_actor+0x65/0xbf
Aug 16 16:07:33 192.168.20.66 kernel: [   61.938123]  [<c014df8e>] generic_file_aio_read+0x2d1/0x4fe
Aug 16 16:07:33 192.168.20.66 kernel: [   61.938123]  [<c0166f71>] do_sync_read+0xab/0xe9
Aug 16 16:07:33 192.168.20.66 kernel: [   61.938123]  [<c0132301>] ? autoremove_wake_function+0x0/0x33
Aug 16 16:07:33 192.168.20.66 kernel: [   61.939066]  [<c013da93>] ? trace_hardirqs_on_caller+0xe1/0x102
Aug 16 16:07:33 192.168.20.66 kernel: [   61.939066]  [<c02bcd89>] ? mutex_unlock+0x8/0xa
Aug 16 16:07:33 192.168.20.66 kernel: [   61.939066]  [<c0166ec6>] ? do_sync_read+0x0/0xe9
Aug 16 16:07:33 192.168.20.66 kernel: [   61.939066]  [<c01677c6>] vfs_read+0x83/0xed
Aug 16 16:07:33 192.168.20.66 kernel: [   61.939066]  [<c01678c9>] sys_read+0x3b/0x60
Aug 16 16:07:33 192.168.20.66 kernel: [   61.940071]  [<c0103861>] sysenter_do_call+0x12/0x35
Aug 16 16:07:33 192.168.20.66 kernel: [   61.940072]  [<c012007b>] ? sys_unshare+0xbf/0x258
Aug 16 16:07:33 192.168.20.66 kernel: [   61.940072]  =======================
Aug 16 16:07:33 192.168.20.66 kernel: [   61.940072] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:08:42 192.168.20.66 kernel: [  130.183597] ------------[ cut here ]------------
Aug 16 16:08:42 192.168.20.66 kernel: [  130.183597] WARNING: at include/linux/skbuff.h:692 bfifo_enqueue+0x66/0xb9()
Aug 16 16:08:42 192.168.20.66 kernel: [  130.183597] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c026a00f>] ? inet_proto_csum_replace4+0x33/0xab
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c025c3be>] ? skb_release_data+0x8e/0x92
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0272c61>] bfifo_enqueue+0x66/0xb9
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<f8a1071a>] tbf_enqueue+0x5c/0x92 [sch_tbf]
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<f8a5275a>] prio_enqueue+0x44/0x82 [sch_prio]
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0261b1c>] dev_queue_xmit+0x339/0x481
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c02804fa>] ip_finish_output+0x1df/0x209
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c02805a2>] ip_output+0x7e/0x83
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c027d1e7>] ip_forward_finish+0x2f/0x32
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c027d3f1>] ip_forward+0x207/0x256
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c027c1ce>] ip_rcv_finish+0x2a6/0x2bc
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c027c3d1>] ip_rcv+0x1ed/0x217
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0261169>] netif_receive_skb+0x3c3/0x3f6
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c026df14>] ? eth_type_trans+0x28/0xcc
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<f890f2f1>] e1000_clean_rx_irq+0x2b2/0x362 [e1000]
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<f89110ac>] e1000_clean+0x2d0/0x474 [e1000]
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c025f9de>] net_rx_action+0xbb/0x1e5
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0106038>] do_IRQ+0xae/0xc4
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0104288>] common_interrupt+0x28/0x30
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006]  =======================
Aug 16 16:08:42 192.168.20.66 kernel: [  130.185006] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:08:58 192.168.20.66 kernel: [  146.592004] ------------[ cut here ]------------
Aug 16 16:08:58 192.168.20.66 kernel: [  146.592004] WARNING: at include/linux/skbuff.h:793 qdisc_dequeue_head+0x5e/0x72()
Aug 16 16:08:58 192.168.20.66 kernel: [  146.592004] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0250032>] ? hid_parse_report+0x1f/0x23d
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<f890ef35>] ? e1000_alloc_rx_buffers+0x16d/0x277 [e1000]
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<f890f379>] ? e1000_clean_rx_irq+0x33a/0x362 [e1000]
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0272eb2>] qdisc_dequeue_head+0x5e/0x72
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<f8a1053f>] tbf_dequeue+0x1c/0x19b [sch_tbf]
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  [<c02b9b45>] start_secondary+0x184/0x189
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004]  =======================
Aug 16 16:08:58 192.168.20.66 kernel: [  146.594004] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:09:03 192.168.20.66 kernel: [  151.431066] ------------[ cut here ]------------
Aug 16 16:09:03 192.168.20.66 kernel: [  151.431066] WARNING: at include/linux/skbuff.h:692 bfifo_enqueue+0x66/0xb9()
Aug 16 16:09:03 192.168.20.66 kernel: [  151.431066] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:09:03 192.168.20.66 kernel: [  151.435005] Pid: 15973, comm: modprobe Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:09:03 192.168.20.66 kernel: [  151.435005]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:09:03 192.168.20.66 kernel: [  151.435005]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:09:03 192.168.20.66 kernel: [  151.435005]  [<c026a00f>] ? inet_proto_csum_replace4+0x33/0xab
Aug 16 16:09:03 192.168.20.66 kernel: [  151.436010]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:09:03 192.168.20.66 kernel: [  151.436040]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:09:03 192.168.20.66 kernel: [  151.436040]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:09:03 192.168.20.66 kernel: [  151.436040]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:09:03 192.168.20.66 kernel: [  151.436040]  [<c0272c61>] bfifo_enqueue+0x66/0xb9
Aug 16 16:09:03 192.168.20.66 kernel: [  151.436040]  [<f8a1071a>] tbf_enqueue+0x5c/0x92 [sch_tbf]
Aug 16 16:09:03 192.168.20.66 kernel: [  151.437013]  [<f8a5275a>] prio_enqueue+0x44/0x82 [sch_prio]
Aug 16 16:09:03 192.168.20.66 kernel: [  151.437013]  [<c0261b1c>] dev_queue_xmit+0x339/0x481
Aug 16 16:09:03 192.168.20.66 kernel: [  151.437013]  [<c02804fa>] ip_finish_output+0x1df/0x209
Aug 16 16:09:03 192.168.20.66 kernel: [  151.437013]  [<c02805a2>] ip_output+0x7e/0x83
Aug 16 16:09:03 192.168.20.66 kernel: [  151.437013]  [<c027d1e7>] ip_forward_finish+0x2f/0x32
Aug 16 16:09:03 192.168.20.66 kernel: [  151.437013]  [<c027d3f1>] ip_forward+0x207/0x256
Aug 16 16:09:03 192.168.20.66 kernel: [  151.438017]  [<c027c1ce>] ip_rcv_finish+0x2a6/0x2bc
Aug 16 16:09:03 192.168.20.66 kernel: [  151.438026]  [<c027c3d1>] ip_rcv+0x1ed/0x217
Aug 16 16:09:03 192.168.20.66 kernel: [  151.438026]  [<c0261169>] netif_receive_skb+0x3c3/0x3f6
Aug 16 16:09:03 192.168.20.66 kernel: [  151.438026]  [<c026df14>] ? eth_type_trans+0x28/0xcc
Aug 16 16:09:03 192.168.20.66 kernel: [  151.438026]  [<f890f2f1>] e1000_clean_rx_irq+0x2b2/0x362 [e1000]
Aug 16 16:09:03 192.168.20.66 kernel: [  151.438026]  [<f89110ac>] e1000_clean+0x2d0/0x474 [e1000]
Aug 16 16:09:03 192.168.20.66 kernel: [  151.439023]  [<c02bdc12>] ? _spin_unlock+0x1d/0x20
Aug 16 16:09:03 192.168.20.66 kernel: [  151.439023]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:09:03 192.168.20.66 kernel: [  151.439023]  [<c025f9de>] net_rx_action+0xbb/0x1e5
Aug 16 16:09:03 192.168.20.66 kernel: [  151.439023]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:09:03 192.168.20.66 kernel: [  151.439023]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:09:03 192.168.20.66 kernel: [  151.439023]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:09:03 192.168.20.66 kernel: [  151.440028]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
Aug 16 16:09:03 192.168.20.66 kernel: [  151.440053]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:09:03 192.168.20.66 kernel: [  151.440053]  [<c0106038>] do_IRQ+0xae/0xc4
Aug 16 16:09:03 192.168.20.66 kernel: [  151.440053]  [<c0104288>] common_interrupt+0x28/0x30
Aug 16 16:09:03 192.168.20.66 kernel: [  151.440053]  [<c01400d8>] ? lockdep_stats_show+0x2e0/0x357
Aug 16 16:09:03 192.168.20.66 kernel: [  151.440053]  [<c01dd728>] ? __copy_to_user_ll+0x5f/0xd7
Aug 16 16:09:03 192.168.20.66 kernel: [  151.441058]  [<c014c03d>] file_read_actor+0x65/0xbf
Aug 16 16:09:03 192.168.20.66 kernel: [  151.441080]  [<c014df8e>] generic_file_aio_read+0x2d1/0x4fe
Aug 16 16:09:03 192.168.20.66 kernel: [  151.441080]  [<c0166f71>] do_sync_read+0xab/0xe9
Aug 16 16:09:03 192.168.20.66 kernel: [  151.441080]  [<c0132301>] ? autoremove_wake_function+0x0/0x33
Aug 16 16:09:03 192.168.20.66 kernel: [  151.441080]  [<c02bcd89>] ? mutex_unlock+0x8/0xa
Aug 16 16:09:03 192.168.20.66 kernel: [  151.441080]  [<c0166ec6>] ? do_sync_read+0x0/0xe9
Aug 16 16:09:03 192.168.20.66 kernel: [  151.442013]  [<c01677c6>] vfs_read+0x83/0xed
Aug 16 16:09:03 192.168.20.66 kernel: [  151.442013]  [<c01678c9>] sys_read+0x3b/0x60
Aug 16 16:09:03 192.168.20.66 kernel: [  151.442013]  [<c0103861>] sysenter_do_call+0x12/0x35
Aug 16 16:09:03 192.168.20.66 kernel: [  151.442013]  [<c012007b>] ? sys_unshare+0xbf/0x258
Aug 16 16:09:03 192.168.20.66 kernel: [  151.442013]  =======================
Aug 16 16:09:03 192.168.20.66 kernel: [  151.442013] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:09:33 192.168.20.66 kernel_read+0x34/0x46
Aug 16 16:09:33 192.168.20.66 kernel: [  181.262068] ------------[ cut here ]------------
Aug 16 16:09:33 192.168.20.66 kernel: [  181.262068] WARNING: at include/linux/skbuff.h:692 qdisc_requeue+0x56/0x6e()
Aug 16 16:09:33 192.168.20.66 kernel: [  181.263013] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:09:33 192.168.20.66 kernel: [  181.266061] Pid: 18331, comm: sh Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:09:33 192.168.20.66 kernel: [  181.267067]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:09:33 192.168.20.66 kernel: [  181.267091]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:09:33 192.168.20.66 kernel: [  181.267091]  [<c0261c31>] ? dev_queue_xmit+0x44e/0x481
Aug 16 16:09:33 192.168.20.66 kernel: [  181.267091]  [<c026e00a>] ? eth_header+0x0/0x8e
Aug 16 16:09:33 192.168.20.66 kernel: [  181.267091]  [<c026e00a>] ? eth_header+0x0/0x8e
Aug 16 16:09:33 192.168.20.66 kernel: [  181.267096]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:09:33 192.168.20.66 kernel: [  181.268034]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:09:33 192.168.20.66 kernel: [  181.268034]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:09:33 192.168.20.66 kernel: [  181.268034]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:09:33 192.168.20.66 kernel: [  181.268034]  [<c0272dbd>] qdisc_requeue+0x56/0x6e
Aug 16 16:09:33 192.168.20.66 kernel: [  181.268034]  [<f8a10689>] tbf_dequeue+0x166/0x19b [sch_tbf]
Aug 16 16:09:33 192.168.20.66 kernel: [  181.269021]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:09:33 192.168.20.66 kernel: [  181.269021]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:09:33 192.168.20.66 kernel: [  181.269021]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:09:33 192.168.20.66 kernel: [  181.269021]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:09:33 192.168.20.66 kernel: [  181.269021]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:09:33 192.168.20.66 kernel: [  181.269021]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:09:33 192.168.20.66 kernel: [  181.270027]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:09:33 192.168.20.66 kernel: [  181.270101]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:09:33 192.168.20.66 kernel: [  181.270101]  [<c0157078>] ? page_address+0x87/0xa9
Aug 16 16:09:33 192.168.20.66 kernel: [  181.270101]  [<c02bdbef>] ? _spin_unlock_irqrestore+0x36/0x3c
Aug 16 16:09:33 192.168.20.66 kernel: [  181.270101]  [<c02bdbf1>] ? _spin_unlock_irqrestore+0x38/0x3c
Aug 16 16:09:33 192.168.20.66 kernel: [  181.270107]  [<c0157078>] page_address+0x87/0xa9
Aug 16 16:09:33 192.168.20.66 kernel: [  181.271013]  [<c016cfca>] ? page_put_link+0x0/0x1b
Aug 16 16:09:33 192.168.20.66 kernel: [  181.271013]  [<c01570b1>] kunmap_high+0x17/0x8e
Aug 16 16:09:33 192.168.20.66 kernel: [  181.271013]  [<c0116630>] kunmap+0x4a/0x4c
Aug 16 16:09:33 192.168.20.66 kernel: [  181.271013]  [<c016cfdb>] page_put_link+0x11/0x1b
Aug 16 16:09:33 192.168.20.66 kernel: [  181.271013]  [<c016ee42>] __link_path_walk+0xa0a/0xb46
Aug 16 16:09:33 192.168.20.66 kernel: [  181.271013]  [<c016f0fd>] path_walk+0x4c/0x9b
Aug 16 16:09:33 192.168.20.66 kernel: [  181.272036]  [<c016f2c2>] do_path_lookup+0x129/0x143
Aug 16 16:09:33 192.168.20.66 kernel: [  181.272036]  [<c016f335>] __path_lookup_intent_open+0x45/0x76
Aug 16 16:09:33 192.168.20.66 kernel: [  181.272036]  [<c016f376>] path_lookup_open+0x10/0x12
Aug 16 16:09:33 192.168.20.66 kernel: [  181.272036]  [<c016b6aa>] open_exec+0x1f/0xa2
Aug 16 16:09:33 192.168.20.66 kernel: [  181.272036]  [<c016b5ae>] ? kernel_read+0x34/0x46
Aug 16 16:09:33 192.168.20.66 kernel: [  181.274041]  [<c018f48a>] load_elf_binary+0x1fe/0x1118
Aug 16 16:09:33 192.168.20.66 kernel: [  181.274165]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:09:33 192.168.20.66 kernel: [  181.274165]  [<c016ab15>] ? search_binary_handler+0x3a/0x1e9
Aug 16 16:09:33 192.168.20.66 kernel: [  181.274165]  [<c018f28c>] ? load_elf_binary+0x0/0x1118
Aug 16 16:09:33 192.168.20.66 kernel: [  181.274165]  [<c016ab5c>] search_binary_handler+0x81/0x1e9
Aug 16 16:09:33 192.168.20.66 kernel: [  181.275064]  [<c016bc35>] do_execve+0x170/0x1e2
Aug 16 16:09:33 192.168.20.66 kernel: [  181.275064]  [<c010236a>] sys_execve+0x29/0x55
Aug 16 16:09:33 192.168.20.66 kernel: [  181.275064]  [<c0103861>] sysenter_do_call+0x12/0x35
Aug 16 16:09:33 192.168.20.66 kernel: [  181.275064]  =======================
Aug 16 16:09:33 192.168.20.66 kernel: [  181.275064] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:10:02 192.168.20.66 kernel: [  210.034004] ------------[ cut here ]------------
Aug 16 16:10:02 192.168.20.66 kernel: [  210.034004] WARNING: at include/linux/skbuff.h:692 bfifo_enqueue+0x66/0xb9()
Aug 16 16:10:02 192.168.20.66 kernel: [  210.034004] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:10:02 192.168.20.66 kernel: [  210.045926] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:10:02 192.168.20.66 kernel: [  210.046915]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:10:02 192.168.20.66 kernel: [  210.046915]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:10:02 192.168.20.66 kernel: [  210.046915]  [<c02bdc12>] ? _spin_unlock+0x1d/0x20
Aug 16 16:10:02 192.168.20.66 kernel: [  210.046915]  [<c016275b>] ? add_partial+0x44/0x49
Aug 16 16:10:02 192.168.20.66 kernel: [  210.046915]  [<c0163309>] ? __slab_free+0x61/0x283
Aug 16 16:10:02 192.168.20.66 kernel: [  210.046915]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0272c61>] bfifo_enqueue+0x66/0xb9
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<f8a1071a>] tbf_enqueue+0x5c/0x92 [sch_tbf]
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<f8a5275a>] prio_enqueue+0x44/0x82 [sch_prio]
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0261b1c>] dev_queue_xmit+0x339/0x481
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c02804fa>] ip_finish_output+0x1df/0x209
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c02805a2>] ip_output+0x7e/0x83
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c027d1e7>] ip_forward_finish+0x2f/0x32
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c027d3f1>] ip_forward+0x207/0x256
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c027c1ce>] ip_rcv_finish+0x2a6/0x2bc
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c027c3d1>] ip_rcv+0x1ed/0x217
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0261169>] netif_receive_skb+0x3c3/0x3f6
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c026df14>] ? eth_type_trans+0x28/0xcc
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<f890f2f1>] e1000_clean_rx_irq+0x2b2/0x362 [e1000]
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<f89110ac>] e1000_clean+0x2d0/0x474 [e1000]
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c025f9de>] net_rx_action+0xbb/0x1e5
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0106038>] do_IRQ+0xae/0xc4
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0104288>] common_interrupt+0x28/0x30
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101]  =======================
Aug 16 16:10:02 192.168.20.66 kernel: [  210.047101] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:10:13 192.168.20.66 kernel: [  221.739003] ------------[ cut here ]------------
Aug 16 16:10:13 192.168.20.66 kernel: [  221.739003] WARNING: at include/linux/skbuff.h:692 qdisc_requeue+0x56/0x6e()
Aug 16 16:10:13 192.168.20.66 kernel: [  221.739003] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:10:13 192.168.20.66 kernel: [  221.769582] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c02bdc12>] ? _spin_unlock+0x1d/0x20
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c016275b>] ? add_partial+0x44/0x49
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c0163309>] ? __slab_free+0x61/0x283
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:10:13 192.168.20.66 kernel: [  221.770028]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c0272dbd>] qdisc_requeue+0x56/0x6e
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<f8a10689>] tbf_dequeue+0x166/0x19b [sch_tbf]
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028]  =======================
Aug 16 16:10:13 192.168.20.66 kernel: [  221.771028] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002] ------------[ cut here ]------------
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002] WARNING: at include/linux/skbuff.h:692 bfifo_enqueue+0x66/0xb9()
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c02bdc12>] ? _spin_unlock+0x1d/0x20
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c016275b>] ? add_partial+0x44/0x49
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0163309>] ? __slab_free+0x61/0x283
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0272c61>] bfifo_enqueue+0x66/0xb9
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<f8a1071a>] tbf_enqueue+0x5c/0x92 [sch_tbf]
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<f8a5275a>] prio_enqueue+0x44/0x82 [sch_prio]
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0261b1c>] dev_queue_xmit+0x339/0x481
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c02804fa>] ip_finish_output+0x1df/0x209
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c02805a2>] ip_output+0x7e/0x83
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c027d1e7>] ip_forward_finish+0x2f/0x32
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c027d3f1>] ip_forward+0x207/0x256
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c027c1ce>] ip_rcv_finish+0x2a6/0x2bc
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c027c3d1>] ip_rcv+0x1ed/0x217
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0261169>] netif_receive_skb+0x3c3/0x3f6
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c026df14>] ? eth_type_trans+0x28/0xcc
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<f890f2f1>] e1000_clean_rx_irq+0x2b2/0x362 [e1000]
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<f89110ac>] e1000_clean+0x2d0/0x474 [e1000]
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c025f9de>] net_rx_action+0xbb/0x1e5
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0106038>] do_IRQ+0xae/0xc4
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0104288>] common_interrupt+0x28/0x30
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002]  =======================
Aug 16 16:10:26 192.168.20.66 kernel: [  234.546002] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:10:31 192.168.20.66 kernel: [  239.450003] ------------[ cut here ]------------
Aug 16 16:10:31 192.168.20.66 kernel: [  239.450003] WARNING: at include/linux/skbuff.h:793 qdisc_dequeue_head+0x5e/0x72()
Aug 16 16:10:31 192.168.20.66 kernel: [  239.450003] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<f89f0032>] ? tcp_packet+0x729/0xa57 [nf_conntrack]
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c02bdb90>] ? _spin_unlock_bh+0x25/0x28
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c0272eb2>] qdisc_dequeue_head+0x5e/0x72
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<f8a1053f>] tbf_dequeue+0x1c/0x19b [sch_tbf]
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c02bdc12>] ? _spin_unlock+0x1d/0x20
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<f8a5201b>] prio_dequeue+0x1b/0x30 [sch_prio]
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c0261b3c>] dev_queue_xmit+0x359/0x481
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451002]  [<c02804fa>] ip_finish_output+0x1df/0x209
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c02805a2>] ip_output+0x7e/0x83
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c027d1e7>] ip_forward_finish+0x2f/0x32
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c027d3f1>] ip_forward+0x207/0x256
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c027c1ce>] ip_rcv_finish+0x2a6/0x2bc
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c027c3d1>] ip_rcv+0x1ed/0x217
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c0261169>] netif_receive_skb+0x3c3/0x3f6
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<c026df14>] ? eth_type_trans+0x28/0xcc
Aug 16 16:10:31 192.168.20.66 kernel: [  239.451003]  [<f890f2f1>] e1000_clean_rx_irq+0x2b2/0x362 [e1000]
Aug 16 16:10:31 192.168.20.66 kernel: [  239.463208]  [<f89110ac>] e1000_clean+0x2d0/0x474 [e1000]
Aug 16 16:10:31 192.168.20.66 kernel: [  239.463384]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:10:31 192.168.20.66 kernel: [  239.463747]  [<c025f9de>] net_rx_action+0xbb/0x1e5
Aug 16 16:10:31 192.168.20.66 kernel: [  239.464197]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:10:31 192.168.20.66 kernel: [  239.464197]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:10:31 192.168.20.66 kernel: [  239.464197]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465188]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465188]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465188]  [<c0106038>] do_IRQ+0xae/0xc4
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465188]  [<c0104288>] common_interrupt+0x28/0x30
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465188]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465188]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465197]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465197]  =======================
Aug 16 16:10:31 192.168.20.66 kernel: [  239.465197] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:11:47 192.168.20.66 kernel: [  315.228593] ------------[ cut here ]------------
Aug 16 16:11:47 192.168.20.66 kernel: [  315.228593] WARNING: at include/linux/skbuff.h:793 qdisc_dequeue_head+0x5e/0x72()
Aug 16 16:11:47 192.168.20.66 kernel: [  315.228593] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0266e18>] ? neigh_resolve_output+0x201/0x24b
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0272eb2>] qdisc_dequeue_head+0x5e/0x72
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<f8a1053f>] tbf_dequeue+0x1c/0x19b [sch_tbf]
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003]  =======================
Aug 16 16:11:47 192.168.20.66 kernel: [  315.229003] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006] ------------[ cut here ]------------
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006] WARNING: at include/linux/skbuff.h:793 qdisc_dequeue_head+0x5e/0x72()
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0250032>] ? hid_parse_report+0x1f/0x23d
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0272eb2>] qdisc_dequeue_head+0x5e/0x72
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<f8a1053f>] tbf_dequeue+0x1c/0x19b [sch_tbf]
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  [<c02b9b45>] start_secondary+0x184/0x189
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006]  =======================
Aug 16 16:11:50 192.168.20.66 kernel: [  318.892006] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:12:49 192.168.20.66 kernel: [  377.171065] ------------[ cut here ]------------
Aug 16 16:12:49 192.168.20.66 kernel: [  377.171065] WARNING: at include/linux/skbuff.h:692 qdisc_requeue+0x56/0x6e()
Aug 16 16:12:49 192.168.20.66 kernel: [  377.171065] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0261c31>] ? dev_queue_xmit+0x44e/0x481
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c026e00a>] ? eth_header+0x0/0x8e
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c026e00a>] ? eth_header+0x0/0x8e
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0272dbd>] qdisc_requeue+0x56/0x6e
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<f8a10689>] tbf_dequeue+0x166/0x19b [sch_tbf]
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  [<c02b9b45>] start_secondary+0x184/0x189
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010]  =======================
Aug 16 16:12:49 192.168.20.66 kernel: [  377.178010] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:12:52 192.168.20.66 kernel: [  380.360065] ------------[ cut here ]------------
Aug 16 16:12:52 192.168.20.66 kernel: [  380.360065] WARNING: at include/linux/skbuff.h:692 qdisc_requeue+0x56/0x6e()
Aug 16 16:12:52 192.168.20.66 kernel: [  380.360065] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:12:52 192.168.20.66 kernel:  ppp_generic slhc
Aug 16 16:12:52 192.168.20.66 kernel:  xt_TCPMSS
Aug 16 16:12:52 192.168.20.66 kernel:  xt_mark
Aug 16 16:12:52 192.168.20.66 kernel:  xt_tcpudp
Aug 16 16:12:52 192.168.20.66 kernel:  iptable_mangle
Aug 16 16:12:52 192.168.20.66 kernel:  iptable_nat
Aug 16 16:12:52 192.168.20.66 kernel:  nf_nat
Aug 16 16:12:52 192.168.20.66 kernel:  nf_conntrack_ipv4
Aug 16 16:12:52 192.168.20.66 kernel:  nf_conntrack
Aug 16 16:12:52 192.168.20.66 kernel:  rtc_cmos
Aug 16 16:12:52 192.168.20.66 kernel:  rtc_core
Aug 16 16:12:52 192.168.20.66 kernel:  rtc_lib iptable_filter
Aug 16 16:12:52 192.168.20.66 kernel:  ip_tables x_tables
Aug 16 16:12:52 192.168.20.66 kernel:  8021q
Aug 16 16:12:52 192.168.20.66 kernel:  garp stp
Aug 16 16:12:52 192.168.20.66 kernel:  llc tun
Aug 16 16:12:52 192.168.20.66 kernel:  loop tulip
Aug 16 16:12:52 192.168.20.66 kernel:  r8169 sky2
Aug 16 16:12:52 192.168.20.66 kernel:  via_velocity via_rhine sis900
Aug 16 16:12:52 192.168.20.66 kernel:  ne2k_pci
Aug 16 16:12:52 192.168.20.66 kernel:  8390
Aug 16 16:12:52 192.168.20.66 kernel:  skge tg3
Aug 16 16:12:52 192.168.20.66 kernel:  libphy 8139too
Aug 16 16:12:52 192.168.20.66 kernel:  e1000 e100
Aug 16 16:12:52 192.168.20.66 kernel:  usb_storage mtdblock mtd_blkdevs
Aug 16 16:12:52 192.168.20.66 kernel:  usbhid
Aug 16 16:12:52 192.168.20.66 kernel:  uhci_hcd
Aug 16 16:12:52 192.168.20.66 kernel:  ehci_hcd ohci_hcd
Aug 16 16:12:52 192.168.20.66 kernel:  usbcore
Aug 16 16:12:52 192.168.20.66 kernel: [  380.364109] Pid: 25174, comm: modprobe Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:12:52 192.168.20.66 kernel: [  380.364109]  [<c02bb7eb>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: printk+0xf/0x14
Aug 16 16:12:52 192.168.20.66 kernel: [  380.364109]  [<c0121be8>]
Aug 16 16:12:52 192.168.20.66 kernel: warn_on_slowpath+0x41/0x65
Aug 16 16:12:52 192.168.20.66 kernel: [  380.365116]  [<c02bdc12>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: _spin_unlock+0x1d/0x20
Aug 16 16:12:52 192.168.20.66 kernel: [  380.365153]  [<c016275b>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: add_partial+0x44/0x49
Aug 16 16:12:52 192.168.20.66 kernel: [  380.365153]  [<c0163309>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: __slab_free+0x61/0x283
Aug 16 16:12:52 192.168.20.66 kernel: [  380.365153]  [<c013dabf>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: trace_hardirqs_on+0xb/0xd
Aug 16 16:12:52 192.168.20.66 kernel: [  380.365153]  [<c013dabf>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: trace_hardirqs_on+0xb/0xd
Aug 16 16:12:52 192.168.20.66 kernel: [  380.366079]  [<c025c000>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: __kfree_skb+0x63/0x66
Aug 16 16:12:52 192.168.20.66 kernel: [  380.366079]  [<c025c000>]
Aug 16 16:12:52 192.168.20.66 kernel: ?
Aug 16 16:12:52 192.168.20.66 kernel: __kfree_skb+0x63/0x66
Aug 16 16:12:52 192.168.20.66 kernel: [  380.366079]  [<c0272dbd>]
Aug 16 16:12:52 192.168.20.66 kernel: qdisc_requeue+0x56/0x6e
Aug 16 16:12:52 192.168.20.66 kernel: [  380.366079]  [<f8a10689>]
Aug 16 16:12:52 192.168.20.66 kernel: tbf_dequeue+0x166/0x19b [sch_tbf]
Aug 16 16:12:52 192.168.20.66 kernel: [  380.366079]  [<c026eace>]
Aug 16 16:12:52 192.168.20.66 kernel: __qdisc_run+0x41/0x18b
Aug 16 16:12:52 192.168.20.66 kernel: [  380.367079]  [<c025fd85>]
Aug 16 16:12:52 192.168.20.66 kernel: net_tx_action+0xaf/0xcc
Aug 16 16:12:52 192.168.20.66 kernel: [  380.367086]  [<c0126203>]
Aug 16 16:12:52 192.168.20.66 kernel: __do_softirq+0x7b/0xf4
Aug 16 16:12:52 192.168.20.66 kernel: [  380.367086]  [<c0126188>]
Aug 16 16:12:52 192.168.20.66 kernel: ? __do_softirq+0x0/0xf4
Aug 16 16:12:52 192.168.20.66 kernel: [  380.367086]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:12:52 192.168.20.66 kernel: [  380.367086]  [<c0125e28>]
Aug 16 16:12:52 192.168.20.66 kernel: irq_exit+0x44/0x79
Aug 16 16:12:52 192.168.20.66 kernel: [  380.368083]  [<c010ff15>]
Aug 16 16:12:52 192.168.20.66 kernel: smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:12:52 192.168.20.66 kernel: [  380.368083]  [<c010438d>]
Aug 16 16:12:52 192.168.20.66 kernel: apic_timer_interrupt+0x2d/0x34
Aug 16 16:12:52 192.168.20.66 kernel: [  380.368083]  [<c012007b>]
Aug 16 16:12:52 192.168.20.66 kernel: ? sys_unshare+0xbf/0x258
Aug 16 16:12:52 192.168.20.66 kernel: [  380.368083]  =======================
Aug 16 16:12:52 192.168.20.66 kernel: [  380.368083] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004] ------------[ cut here ]------------
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004] WARNING: at include/linux/skbuff.h:692 bfifo_enqueue+0x66/0xb9()
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:13:11 192.168.20.66 kernel: [  399.643004]  [<c026a00f>] ? inet_proto_csum_replace4+0x33/0xab
Aug 16 16:13:11 192.168.20.66 kernel: [  399.656071]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:13:11 192.168.20.66 kernel: [  399.656266]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:13:11 192.168.20.66 kernel: [  399.656649]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:13:11 192.168.20.66 kernel: [  399.657066]  [<c025c000>] ? __kfree_skb+0x63/0x66
Aug 16 16:13:11 192.168.20.66 kernel: [  399.657066]  [<c0272c61>] bfifo_enqueue+0x66/0xb9
Aug 16 16:13:11 192.168.20.66 kernel: [  399.657066]  [<f8a1071a>] tbf_enqueue+0x5c/0x92 [sch_tbf]
Aug 16 16:13:11 192.168.20.66 kernel: [  399.658066]  [<f8a5275a>] prio_enqueue+0x44/0x82 [sch_prio]
Aug 16 16:13:11 192.168.20.66 kernel: [  399.658066]  [<c0261b1c>] dev_queue_xmit+0x339/0x481
Aug 16 16:13:11 192.168.20.66 kernel: [  399.658066]  [<c02804fa>] ip_finish_output+0x1df/0x209
Aug 16 16:13:11 192.168.20.66 kernel: [  399.658066]  [<c02805a2>] ip_output+0x7e/0x83
Aug 16 16:13:11 192.168.20.66 kernel: [  399.658066]  [<c027d1e7>] ip_forward_finish+0x2f/0x32
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c027d3f1>] ip_forward+0x207/0x256
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c027c1ce>] ip_rcv_finish+0x2a6/0x2bc
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c027c3d1>] ip_rcv+0x1ed/0x217
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0261169>] netif_receive_skb+0x3c3/0x3f6
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c026df14>] ? eth_type_trans+0x28/0xcc
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<f890f2f1>] e1000_clean_rx_irq+0x2b2/0x362 [e1000]
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<f89110ac>] e1000_clean+0x2d0/0x474 [e1000]
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c025f9de>] net_rx_action+0xbb/0x1e5
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0106038>] do_IRQ+0xae/0xc4
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0104288>] common_interrupt+0x28/0x30
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  [<c02b9b45>] start_secondary+0x184/0x189
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065]  =======================
Aug 16 16:13:11 192.168.20.66 kernel: [  399.659065] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:13:42 192.168.20.66 kernel: [  430.623004] ------------[ cut here ]------------
Aug 16 16:13:42 192.168.20.66 kernel: [  430.623004] WARNING: at include/linux/skbuff.h:793 qdisc_dequeue_head+0x5e/0x72()
Aug 16 16:13:42 192.168.20.66 kernel: [  430.623004] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0250032>] ? hid_parse_report+0x1f/0x23d
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<f890ef35>] ? e1000_alloc_rx_buffers+0x16d/0x277 [e1000]
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<f890f379>] ? e1000_clean_rx_irq+0x33a/0x362 [e1000]
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0272eb2>] qdisc_dequeue_head+0x5e/0x72
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<f8a1053f>] tbf_dequeue+0x1c/0x19b [sch_tbf]
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  [<c02b1016>] rest_init+0x4e/0x50
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003]  =======================
Aug 16 16:13:42 192.168.20.66 kernel: [  430.625003] ---[ end trace 7e8f04d781fe52f3 ]---
Aug 16 16:14:02 192.168.20.66 kernel: [  450.101006] ------------[ cut here ]------------
Aug 16 16:14:02 192.168.20.66 kernel: [  450.101006] WARNING: at include/linux/skbuff.h:793 qdisc_dequeue_head+0x5e/0x72()
Aug 16 16:14:02 192.168.20.66 kernel: [  450.101006] Modules linked in: sch_ingress sch_prio netconsole configfs nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre iTCO_wdt 
e752x_edac edac_core cls_u32 em_meta cls_basic xt_dscp xt_DSCP ipt_REJECT
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008] Pid: 0, comm: swapper Tainted: G        W 2.6.27-rc3-git2-build-0031 #15
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c02bb7eb>] ? printk+0xf/0x14
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c0261c31>] ? dev_queue_xmit+0x44e/0x481
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c026e00a>] ? eth_header+0x0/0x8e
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c026e00a>] ? eth_header+0x0/0x8e
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<f8a056e2>] ? ppp_push+0x7f/0x407 [ppp_generic]
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c012604d>] ? local_bh_enable_ip+0xa6/0xaa
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c02bdb90>] ? _spin_unlock_bh+0x25/0x28
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<f8a062b2>] ? ppp_xmit_process+0x459/0x461 [ppp_generic]
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c0272eb2>] qdisc_dequeue_head+0x5e/0x72
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<f8a1053f>] tbf_dequeue+0x1c/0x19b [sch_tbf]
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c02bdcc0>] ? _spin_lock+0x22/0x2a
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c026eace>] __qdisc_run+0x41/0x18b
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c025fd85>] net_tx_action+0xaf/0xcc
Aug 16 16:14:02 192.168.20.66 kernel: [  450.119008]  [<c0126203>] __do_softirq+0x7b/0xf4
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c0126188>] ? __do_softirq+0x0/0xf4
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c01060b3>] do_softirq+0x65/0xb6
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c0125e28>] irq_exit+0x44/0x79
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c010ff15>] smp_apic_timer_interrupt+0x6f/0x7d
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c010438d>] apic_timer_interrupt+0x2d/0x34
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c0108d8a>] ? mwait_idle+0x39/0x43
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c01029ee>] cpu_idle+0xbf/0xe1
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  [<c02b9b45>] start_secondary+0x184/0x189
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002]  =======================
Aug 16 16:14:02 192.168.20.66 kernel: [  450.125002] ---[ end trace 7e8f04d781fe52f3 ]---

