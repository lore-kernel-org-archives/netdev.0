From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 00:21:57 -0800
Message-ID: <20071123002157.cb27f4a1.akpm@linux-foundation.org>
References: <4745DCD7.8070805@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57958 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753252AbXKWIWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:22:42 -0500
In-Reply-To: <4745DCD7.8070805@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Nov 2007 19:47:35 +0000 Simon Arlott <simon@fire.lp0.eu> wrote:

> WARN during log message being output to ttyS0 and netconsole:
> 
> [2059664.615816] __iptables__: init4 IN=ppp0 OUT=ppp0 WARNING: at kernel/softirq.c:139 local_bh_enable()
> [2059664.620535]  [<80120364>] local_bh_enable+0x3c/0x97
> [2059664.620553]  [<802e3356>] __nf_ct_ext_destroy+0x35/0x5b
> [2059664.620569]  [<802dfbeb>] destroy_conntrack+0x5e/0xf6
> [2059664.620577]  [<802db821>] nf_conntrack_destroy+0x1f/0x3f
> [2059664.620585]  [<802c0c71>] __kfree_skb+0xb8/0xf6
> [2059664.620597]  [<802d00f0>] zap_completion_queue+0x3e/0x64
> [2059664.620606]  [<802d0583>] find_skb+0x14/0x6b
> [2059664.620612]  [<801167cc>] inc_nr_running+0x12/0x25
> [2059664.620622]  [<802d0fd8>] netpoll_send_udp+0x2d/0x251
> [2059664.620630]  [<80226135>] uart_console_write+0x2a/0x33
> [2059664.620645]  [<80241319>] write_msg+0x32/0x41
> [2059664.620657]  [<8011c205>] __call_console_drivers+0x61/0x6d
> [2059664.620669]  [<8011c3fc>] release_console_sem+0x164/0x1bf
> [2059664.620679]  [<8011c81f>] vprintk+0x27a/0x2ff
> [2059664.620692]  [<8013881e>] handle_IRQ_event+0x1a/0x3f
> [2059664.620702]  [<801203a5>] local_bh_enable+0x7d/0x97
> [2059664.620709]  [<8031ae6a>] fn_hash_lookup+0xb0/0xcd
> [2059664.620723]  [<8011c8bf>] printk+0x1b/0x1f
> [2059664.620731]  [<8032b372>] ipt_log_packet+0x71/0x15e
> [2059664.620747]  [<8032b4a0>] ipt_log_target+0x41/0x4a
> [2059664.620757]  [<802ea446>] ipt_limit_match+0x58/0x76
> [2059664.620766]  [<8032b45f>] ipt_log_target+0x0/0x4a
> [2059664.620774]  [<803288c5>] ipt_do_table+0x3e2/0x479
> [2059664.620785]  [<80331228>] xfrm_policy_put_afinfo+0xa/0x1e
> [2059664.620800]  [<80332219>] xfrm_lookup+0x15/0x69
> [2059664.620809]  [<802db7d0>] nf_iterate+0x38/0x6a
> [2059664.620822]  [<802dbb60>] nf_hook_slow+0x57/0xe0
> [2059664.620830]  [<802f1e7c>] ip_forward_finish+0x0/0x22
> [2059664.620841]  [<802f20d1>] ip_forward+0x233/0x2ae
> [2059664.620849]  [<802f1e7c>] ip_forward_finish+0x0/0x22
> [2059664.620859]  [<802f0e7a>] ip_rcv+0x46f/0x49c
> [2059664.620866]  [<802f04a8>] ip_rcv_finish+0x0/0x2ab
> [2059664.620876]  [<802f0a0b>] ip_rcv+0x0/0x49c
> [2059664.620884]  [<802c544a>] netif_receive_skb+0x326/0x3ae
> [2059664.620894]  [<802c6efe>] process_backlog+0x6d/0xd2
> [2059664.620903]  [<802c766e>] net_rx_action+0x86/0x193
> [2059664.620911]  [<80120001>] __do_softirq+0x40/0x85
> [2059664.620919]  [<8012006d>] do_softirq+0x27/0x2b
> [2059664.620925]  [<8012023d>] irq_exit+0x2d/0x37
> [2059664.620931]  [<801062d9>] do_IRQ+0x7a/0x8d
> [2059664.620943]  [<8010479b>] common_interrupt+0x23/0x28
> [2059664.620954]  [<80209f85>] acpi_processor_idle+0x235/0x3a0
> [2059664.620967]  [<80102344>] cpu_idle+0x43/0x6c
> [2059664.620973]  [<804aa99e>] start_kernel+0x210/0x215
> [2059664.620989]  [<804aa317>] unknown_bootoption+0x0/0x195
> [2059664.620998]  =======================
> [2059664.852188] SRC=66.249.93.147 DST=* LEN=40 TOS=0x00 PREC=0x00 TTL=53 ID=23868 DF PROTO=TCP SPT=80 DPT=55219 WINDOW=0 RES=0x00 RST URGP=0

If that trace is to be beieved we're doing nefilter stuff on packets which
were sent across netconsole.

This probably isn't anything the netfilter guys have thought about.  And
probably we don't want them to.  Is there some simple way in which we can
exempt netconsole from netfilter processing?
