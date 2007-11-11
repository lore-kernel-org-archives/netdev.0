From: Chazarain Guillaume <guichaz@yahoo.fr>
Subject: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571 tcp_remove_reno_sacks()
Date: Sun, 11 Nov 2007 12:53:49 +0000 (GMT)
Message-ID: <702223.57929.qm@web26203.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26203.mail.ukl.yahoo.com ([217.12.10.240]:45554 "HELO
	web26203.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752745AbXKKMxv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 07:53:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I'm currently running bittorrent with all of this, I just saw this (for
 the first time ever),
> but otherwise it works fine:
> 
> WARNING: at net/ipv4/tcp_output.c:1807 tcp_simple_retransmit()
>  [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
>  [<c0105563>] show_trace+0x12/0x14
>  [<c0105668>] dump_stack+0x15/0x17
>  [<c02f6a79>] tcp_simple_retransmit+0xfa/0x185
>  [<c02fa072>] tcp_v4_err+0x35d/0x4cb
>  [<c0301f7d>] icmp_unreach+0x327/0x352
>  [<c030159d>] icmp_rcv+0xe0/0xf7
>  [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
>  [<c02e3178>] ip_local_deliver+0x72/0x7e
>  [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
>  [<c02e30e8>] ip_rcv+0x1e1/0x1ff
>  [<c02c755c>] netif_receive_skb+0x37d/0x401
>  [<c02c9372>] process_backlog+0x5b/0x96
>  [<c02c9037>] net_rx_action+0x87/0x152
>  [<c0121c9f>] __do_softirq+0x38/0x7a
>  [<c0105975>] do_softirq+0x41/0x92

I don't know if it's caused by the disabling of tcp_sack, but bittorrenting the whole night, I
have a lot more of tcp_verify_left_out() warnings in the logs:

WARNING: at net/ipv4/tcp_output.c:1807 tcp_simple_retransmit()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f6a79>] tcp_simple_retransmit+0xfa/0x185
 [<c02fa072>] tcp_v4_err+0x35d/0x4cb
 [<c0301f7d>] icmp_unreach+0x327/0x352
 [<c030159d>] icmp_rcv+0xe0/0xf7
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_input.c:2405 tcp_fastretrans_alert()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f05a3>] tcp_ack+0xd8c/0x17dd
 [<c02f36bd>] tcp_rcv_established+0xdb/0x5f2
 [<c02f8bc5>] tcp_v4_do_rcv+0x2b/0x310
 [<c02faa0b>] tcp_v4_rcv+0x82b/0x89d
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_input.c:2405 tcp_fastretrans_alert()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f05a3>] tcp_ack+0xd8c/0x17dd
 [<c02f3b03>] tcp_rcv_established+0x521/0x5f2
 [<c02f8bc5>] tcp_v4_do_rcv+0x2b/0x310
 [<c02faa0b>] tcp_v4_rcv+0x82b/0x89d
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_input.c:1672 tcp_enter_frto()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f2a60>] tcp_enter_frto+0x166/0x1db
 [<c02f7a06>] tcp_write_timer+0x3aa/0x5bc
 [<c01249b4>] run_timer_softirq+0x105/0x177
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_input.c:2941 tcp_process_frto()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f014b>] tcp_ack+0x934/0x17dd
 [<c02f3b03>] tcp_rcv_established+0x521/0x5f2
 [<c02f8bc5>] tcp_v4_do_rcv+0x2b/0x310
 [<c02faa0b>] tcp_v4_rcv+0x82b/0x89d
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_input.c:2405 tcp_fastretrans_alert()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f05a3>] tcp_ack+0xd8c/0x17dd
 [<c02f3b03>] tcp_rcv_established+0x521/0x5f2
 [<c02f8bc5>] tcp_v4_do_rcv+0x2b/0x310
 [<c02faa0b>] tcp_v4_rcv+0x82b/0x89d
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_input.c:2306 tcp_try_to_open()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f0a8c>] tcp_ack+0x1275/0x17dd
 [<c02f3b03>] tcp_rcv_established+0x521/0x5f2
 [<c02f8bc5>] tcp_v4_do_rcv+0x2b/0x310
 [<c02faa0b>] tcp_v4_rcv+0x82b/0x89d
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================
WARNING: at net/ipv4/tcp_output.c:1807 tcp_simple_retransmit()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f6a79>] tcp_simple_retransmit+0xfa/0x185
 [<c02fa072>] tcp_v4_err+0x35d/0x4cb
 [<c0301f7d>] icmp_unreach+0x327/0x352
 [<c030159d>] icmp_rcv+0xe0/0xf7
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92
 =======================


Cheers.

-- 
Guillaume





      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail 
