From: Crazy AMD K7 <snort2004@mail.ru>
Subject: do_IRQ: stack overflow: 956 Fwd: Re: do_IRQ: stack overflow: 872..
Date: Sat, 8 Jan 2005 23:29:08 +0300
Message-ID: <15912343549.20050108232908@mail.ru>
Reply-To: Crazy AMD K7 <snort2004@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <ak@suse.de>,
        Bart De Schuymer <bdschuym@pandora.be>, <bridge@osdl.org>,
        <netdev@oss.sgi.com>, Rusty Russell <rusty@rustcorp.com.au>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Crazy AMD K7 <snort2004@mail.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

May be it will be interesting, may be not, but the situation
with stack overflow appeared at my system again.

2.4.28 kernel
+ ebtables-brnf-8_vs_2.4.28.diff
+ fixbrnf.diff
+ u32 (from patch-o-matic)

Here are the results:
ksymoops 2.4.4 on i686 2.4.28.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.28/ (default)
     -m /boot/System.map-2.4.28-fixed (specified)

Jan  6 18:49:04 localhost kernel: do_IRQ: stack overflow: 956
Jan  6 18:49:04 localhost kernel: c02623f4 000003bc dfe65f00 00000001 0000000b ceb1c9d8 c010a508 dfe65f00
Jan  6 18:49:04 localhost kernel:        0000000b 0000000b 00000001 0000000b ceb1c9d8 04000000 00000018 00000018 
Jan  6 18:49:04 localhost kernel:        ffffff0c c0108069 00000010 00000246 ceb1c9d8 0000000b c0300bc0 dfe65f00 
Jan  6 18:49:04 localhost kernel: Call Trace:    [<c010a508>] [<c0108069>] [<c0108208>] [<c010a508>] [<c025769b>]
Jan  6 18:49:04 localhost kernel:   [<c0208dc8>] [<c020777b>] [<c020790d>] [<c01be170>] [<c020afd5>] [<c02530e0>]
Jan  6 18:49:04 localhost kernel:   [<c02146fc>] [<c020b1de>] [<c02530e0>] [<c024642c>] [<c0253199>] [<c02130b3>]
Jan  6 18:49:04 localhost kernel:   [<c02530e0>] [<c02530e0>] [<c021342e>] [<c0213460>] [<c01be937>] [<c0256e10>]
Jan  6 18:49:04 localhost kernel:   [<c02530e0>] [<c0244098>] [<c02530e0>] [<c02130b3>] [<c02530e0>] [<c02530e0>]
Jan  6 18:49:04 localhost kernel:   [<c021342e>] [<c02530e0>] [<c02130b3>] [<c02531b0>] [<c02531e9>] [<c02530e0>]
Jan  6 18:49:04 localhost kernel:   [<c0213460>] [<c020b1de>] [<c02531b0>] [<c0256cbf>] [<c02531b0>] [<c0208dc8>]
Jan  6 18:49:04 localhost kernel:   [<c02531b0>] [<c02130b3>] [<c02531b0>] [<c02531b0>] [<c021342e>] [<c02531b0>]
Jan  6 18:49:04 localhost kernel:   [<c020777b>] [<c020790d>] [<c025322a>] [<c02531b0>] [<c02532ab>] [<c025276a>]
Jan  6 18:49:04 localhost kernel:   [<c020b02e>] [<c025279d>] [<c020b255>] [<c02530e0>] [<c02530e0>] [<c021342e>]
Jan  6 18:49:04 localhost kernel:   [<c0213460>] [<c021e9e7>] [<c0256e10>] [<c021e940>] [<c021e940>] [<c0256f42>]
Jan  6 18:49:04 localhost kernel:   [<c02130b3>] [<c021e940>] [<c021e940>] [<c021342e>] [<c021e940>] [<c0108079>]
Jan  6 18:49:04 localhost kernel:   [<c021d649>] [<c021e940>] [<c0208dc8>] [<c020777b>] [<c020790d>] [<c021eb60>]
Jan  6 18:49:04 localhost kernel:   [<c0246498>] [<c021ea40>] [<c021ea40>] [<c0256f42>] [<c02130b3>] [<c021ea40>]
Jan  6 18:49:04 localhost kernel:   [<c021ea40>] [<c021342e>] [<c021ea40>] [<c02130b3>] [<c021dac1>] [<c021ea40>]
Jan  6 18:49:04 localhost kernel:   [<c0213460>] [<c0208dc8>] [<c0256e10>] [<c02530e0>] [<c0244098>] [<c023296d>]
Jan  6 18:49:04 localhost kernel:   [<c022db29>] [<c02292c1>] [<c02530e0>] [<c022e5e1>] [<c022b929>] [<c0256cbf>]
Jan  6 18:49:04 localhost kernel:   [<c022bd67>] [<c02531b0>] [<c02130b3>] [<c02531b0>] [<c02531b0>] [<c021342e>]
Jan  6 18:49:04 localhost kernel:   [<c02531b0>] [<c020777b>] [<c020790d>] [<c025322a>] [<c02088f5>] [<c0233719>]
Jan  6 18:49:04 localhost kernel:   [<c023366e>] [<c0233bc4>] [<c0244098>] [<c021acb0>] [<c02463ac>] [<c021ad67>]
Jan  6 18:49:04 localhost kernel:   [<c021acb0>] [<c021acb0>] [<c021342e>] [<c021acb0>] [<c0213460>] [<c02560c0>]
Jan  6 18:49:04 localhost kernel:   [<c024642c>] [<c021ade0>] [<c021a93c>] [<c021acb0>] [<c02560c0>] [<c02188fd>]
Jan  6 18:49:04 localhost kernel:   [<c021ade0>] [<c021ade0>] [<c021af4b>] [<c0253b70>] [<c02568c0>] [<c021ade0>]
Jan  6 18:49:04 localhost kernel:   [<c0256e3b>] [<c02130b3>] [<c021ade0>] [<c021ade0>] [<c021342e>] [<c021ade0>]
Jan  6 18:49:04 localhost kernel:   [<c021ea40>] [<c021ac7d>] [<c021ade0>] [<c0253b70>] [<c0233719>] [<c0250f2c>]
Jan  6 18:49:04 localhost kernel:   [<c0253b70>] [<c02075a1>] [<c020b7df>] [<c023296d>] [<c020b87d>] [<c020b99c>]
Jan  6 18:49:04 localhost kernel:   [<c0108079>] [<c01176cb>] [<c010823c>] [<c010a508>] [<c0163161>] [<c015ec35>]
Jan  6 18:49:04 localhost kernel:   [<c020b435>] [<c02075a1>] [<c01be64d>] [<c015ec8f>] [<c0158441>] [<c022db29>]
Jan  6 18:49:04 localhost kernel:   [<c02292c1>] [<c0233719>] [<c0253ac0>] [<c021342e>] [<c016320b>] [<c015ec35>]
Jan  6 18:49:04 localhost kernel:   [<c0132e86>] [<c015ec97>] [<c0158ab0>] [<c016320b>] [<c0158a53>] [<c0158b57>]
Jan  6 18:49:04 localhost kernel:   [<c0158c2c>] [<c015ef55>] [<c014312e>] [<c015384a>] [<c016320b>] [<c015ec35>]
Jan  6 18:49:04 localhost kernel:   [<c021ade0>] [<c021ade0>] [<c021af4b>] [<c0256e3b>] [<c015f29d>] [<c0158728>]
Jan  6 18:49:04 localhost kernel:   [<c0158791>] [<c021ade0>] [<c021ade0>] [<c021342e>] [<c016320b>] [<c015ec35>]
Jan  6 18:49:04 localhost kernel:   [<c0132e86>] [<c015ec97>] [<c016320b>] [<c015ec35>] [<c0155b79>] [<c0155e95>]
Jan  6 18:49:04 localhost kernel:   [<c0132bf8>] [<c0132c09>] [<c0132e86>] [<c0158728>] [<c0158791>] [<c0155d03>]
Jan  6 18:49:04 localhost kernel:   [<c015656d>] [<c01330b1>] [<c01566c9>] [<c0133616>] [<c0164f07>] [<c0133ecd>]
Jan  6 18:49:04 localhost kernel:   [<c0156670>] [<c0156b1c>] [<c0156670>] [<c01297f5>] [<c012339d>] [<c0125ec5>]
Jan  6 18:49:04 localhost kernel:   [<c0126320>] [<c015467f>] [<c0131175>] [<c013eea8>] [<c0108208>] [<c0116feb>]
Jan  6 18:49:04 localhost kernel:   [<c0106cb3>]
Warning (Oops_read): Code line not seen, dumping what data is available

Trace; c010a508 <call_do_IRQ+5/d>
Trace; c0108069 <handle_IRQ_event+29/60>
Trace; c0108208 <do_IRQ+88/d0>
Trace; c010a508 <call_do_IRQ+5/d>
Trace; c025769b <_mmx_memcpy+2b/150>
Trace; c0208dc8 <skb_copy_and_csum_dev+78/d0>
Trace; c020777b <kfree_skbmem+b/60>
Trace; c020790d <__kfree_skb+13d/150>
Trace; c01be170 <rtl8139_start_xmit+50/100>
Trace; c020afd5 <dev_queue_xmit_nit+15/a0>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c02146fc <qdisc_restart+4c/d0>
Trace; c020b1de <dev_queue_xmit+fe/260>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c024642c <ipt_route_hook+1c/20>
Trace; c0253199 <br_dev_queue_push_xmit+b9/d0>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c0213460 <nf_hook_slow+e0/140>
Trace; c01be937 <rtl8139_interrupt+d7/120>
Trace; c0256e10 <br_nf_post_routing+140/150>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c0244098 <ipt_do_table+308/450>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c02531e9 <br_forward_finish+39/40>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c0213460 <nf_hook_slow+e0/140>
Trace; c020b1de <dev_queue_xmit+fe/260>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c0256cbf <br_nf_local_out+19f/1b0>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c0208dc8 <skb_copy_and_csum_dev+78/d0>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c020777b <kfree_skbmem+b/60>
Trace; c020790d <__kfree_skb+13d/150>
Trace; c025322a <__br_deliver+3a/40>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c02532ab <br_deliver+2b/50>
Trace; c025276a <__br_dev_xmit+6a/90>
Trace; c020b02e <dev_queue_xmit_nit+6e/a0>
Trace; c025279d <br_dev_xmit+d/10>
Trace; c020b255 <dev_queue_xmit+175/260>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c0213460 <nf_hook_slow+e0/140>
Trace; c021e9e7 <ip_finish_output2+a7/100>
Trace; c0256e10 <br_nf_post_routing+140/150>
Trace; c021e940 <ip_finish_output2+0/100>
Trace; c021e940 <ip_finish_output2+0/100>
Trace; c0256f42 <ip_sabotage_out+f2/110>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c021e940 <ip_finish_output2+0/100>
Trace; c021e940 <ip_finish_output2+0/100>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c021e940 <ip_finish_output2+0/100>
Trace; c0108079 <handle_IRQ_event+39/60>
Trace; c021d649 <ip_output+139/150>
Trace; c021e940 <ip_finish_output2+0/100>
Trace; c0208dc8 <skb_copy_and_csum_dev+78/d0>
Trace; c020777b <kfree_skbmem+b/60>
Trace; c020790d <__kfree_skb+13d/150>
Trace; c021eb60 <ip_queue_xmit2+120/1f7>
Trace; c0246498 <ipt_local_hook+68/b0>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c0256f42 <ip_sabotage_out+f2/110>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c021dac1 <ip_queue_xmit+461/4b0>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c0213460 <nf_hook_slow+e0/140>
Trace; c0208dc8 <skb_copy_and_csum_dev+78/d0>
Trace; c0256e10 <br_nf_post_routing+140/150>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c0244098 <ipt_do_table+308/450>
Trace; c023296d <tcp_v4_send_check+6d/b0>
Trace; c022db29 <tcp_transmit_skb+549/670>
Trace; c02292c1 <tcp_clean_rtx_queue+221/320>
Trace; c02530e0 <br_dev_queue_push_xmit+0/d0>
Trace; c022e5e1 <tcp_write_xmit+151/290>
Trace; c022b929 <__tcp_data_snd_check+49/d0>
Trace; c0256cbf <br_nf_local_out+19f/1b0>
Trace; c022bd67 <tcp_rcv_established+137/8d0>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c02531b0 <br_forward_finish+0/40>
Trace; c020777b <kfree_skbmem+b/60>
Trace; c020790d <__kfree_skb+13d/150>
Trace; c025322a <__br_deliver+3a/40>
Trace; c02088f5 <skb_checksum+45/240>
Trace; c0233719 <tcp_v4_do_rcv+29/100>
Trace; c023366e <tcp_v4_checksum_init+7e/100>
Trace; c0233bc4 <tcp_v4_rcv+3d4/620>
Trace; c0244098 <ipt_do_table+308/450>
Trace; c021acb0 <ip_local_deliver_finish+0/130>
Trace; c02463ac <ipt_hook+1c/20>
Trace; c021ad67 <ip_local_deliver_finish+b7/130>
Trace; c021acb0 <ip_local_deliver_finish+0/130>
Trace; c021acb0 <ip_local_deliver_finish+0/130>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c021acb0 <ip_local_deliver_finish+0/130>
Trace; c0213460 <nf_hook_slow+e0/140>
Trace; c02560c0 <br_nf_pre_routing_finish+0/1f0>
Trace; c024642c <ipt_route_hook+1c/20>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021a93c <ip_local_deliver+17c/190>
Trace; c021acb0 <ip_local_deliver_finish+0/130>
Trace; c02560c0 <br_nf_pre_routing_finish+0/1f0>
Trace; c02188fd <ip_route_input+3d/130>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021af4b <ip_rcv_finish+16b/1a0>
Trace; c0253b70 <br_handle_frame_finish+0/110>
Trace; c02568c0 <br_nf_pre_routing+330/350>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c0256e3b <ip_sabotage_in+1b/30>
Trace; c02130b3 <nf_iterate+33/90>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021ea40 <ip_queue_xmit2+0/1f7>
Trace; c021ac7d <ip_rcv+32d/360>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c0253b70 <br_handle_frame_finish+0/110>
Trace; c0233719 <tcp_v4_do_rcv+29/100>
Trace; c0250f2c <packet_rcv+ec/260>
Trace; c0253b70 <br_handle_frame_finish+0/110>
Trace; c02075a1 <alloc_skb+d1/190>
Trace; c020b7df <netif_receive_skb+17f/1b0>
Trace; c023296d <tcp_v4_send_check+6d/b0>
Trace; c020b87d <process_backlog+6d/120>
Trace; c020b99c <net_rx_action+6c/100>
Trace; c0108079 <handle_IRQ_event+39/60>
Trace; c01176cb <do_softirq+4b/90>
Trace; c010823c <do_IRQ+bc/d0>
Trace; c010a508 <call_do_IRQ+5/d>
Trace; c0163161 <journal_cancel_revoke+51/170>
Trace; c015ec35 <do_get_write_access+4b5/4e0>
Trace; c020b435 <netif_rx+75/160>
Trace; c02075a1 <alloc_skb+d1/190>
Trace; c01be64d <rtl8139_rx_interrupt+1ad/2a0>
Trace; c015ec8f <journal_get_write_access+2f/50>
Trace; c0158441 <ext3_do_update_inode+41/3c0>
Trace; c022db29 <tcp_transmit_skb+549/670>
Trace; c02292c1 <tcp_clean_rtx_queue+221/320>
Trace; c0233719 <tcp_v4_do_rcv+29/100>
Trace; c0253ac0 <br_pass_frame_up_finish+0/10>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c016320b <journal_cancel_revoke+fb/170>
Trace; c015ec35 <do_get_write_access+4b5/4e0>
Trace; c0132e86 <bread+16/80>
Trace; c015ec97 <journal_get_write_access+37/50>
Trace; c0158ab0 <ext3_reserve_inode_write+30/b0>
Trace; c016320b <journal_cancel_revoke+fb/170>
Trace; c0158a53 <ext3_mark_iloc_dirty+23/50>
Trace; c0158b57 <ext3_mark_inode_dirty+27/40>
Trace; c0158c2c <ext3_dirty_inode+bc/100>
Trace; c015ef55 <journal_get_undo_access+f5/120>
Trace; c014312e <__mark_inode_dirty+2e/90>
Trace; c015384a <ext3_new_block+aa/830>
Trace; c016320b <journal_cancel_revoke+fb/170>
Trace; c015ec35 <do_get_write_access+4b5/4e0>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021af4b <ip_rcv_finish+16b/1a0>
Trace; c0256e3b <ip_sabotage_in+1b/30>
Trace; c015f29d <journal_dirty_metadata+17d/1a0>
Trace; c0158728 <ext3_do_update_inode+328/3c0>
Trace; c0158791 <ext3_do_update_inode+391/3c0>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021ade0 <ip_rcv_finish+0/1a0>
Trace; c021342e <nf_hook_slow+ae/140>
Trace; c016320b <journal_cancel_revoke+fb/170>
Trace; c015ec35 <do_get_write_access+4b5/4e0>
Trace; c0132e86 <bread+16/80>
Trace; c015ec97 <journal_get_write_access+37/50>
Trace; c016320b <journal_cancel_revoke+fb/170>
Trace; c015ec35 <do_get_write_access+4b5/4e0>
Trace; c0155b79 <ext3_alloc_block+19/20>
Trace; c0155e95 <ext3_alloc_branch+55/2d0>
Trace; c0132bf8 <getblk+28/60>
Trace; c0132c09 <getblk+39/60>
Trace; c0132e86 <bread+16/80>
Trace; c0158728 <ext3_do_update_inode+328/3c0>
Trace; c0158791 <ext3_do_update_inode+391/3c0>
Trace; c0155d03 <ext3_get_branch+53/d0>
Trace; c015656d <ext3_get_block_handle+1bd/2c0>
Trace; c01330b1 <create_buffers+61/f0>
Trace; c01566c9 <ext3_get_block+59/60>
Trace; c0133616 <__block_prepare_write+e6/300>
Trace; c0164f07 <__jbd_kmalloc+27/a0>
Trace; c0133ecd <block_prepare_write+1d/40>
Trace; c0156670 <ext3_get_block+0/60>
Trace; c0156b1c <ext3_prepare_write+7c/120>
Trace; c0156670 <ext3_get_block+0/60>
Trace; c01297f5 <lru_cache_add+65/70>
Trace; c012339d <add_to_page_cache_unique+9d/b0>
Trace; c0125ec5 <do_generic_file_write+255/3e0>
Trace; c0126320 <generic_file_write+f0/110>
Trace; c015467f <ext3_file_write+1f/b0>
Trace; c0131175 <sys_write+95/f0>
Trace; c013eea8 <sys_select+468/480>
Trace; c0108208 <do_IRQ+88/d0>
Trace; c0116feb <sys_gettimeofday+1b/a0>
Trace; c0106cb3 <system_call+33/38>


1 warning issued.  Results may not be reliable.
