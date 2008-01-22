From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: WARNING, tcp_fastretrans_alert, rc6-git11
Date: Tue, 22 Jan 2008 23:20:41 +0200
Message-ID: <20080122211652.M43631@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:54773 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbYAVVVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 16:21:06 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 32E75BD036
	for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 23:20:41 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just got on one of proxies, under high load.
It is a bit old rc, so probably my report not interesting, but since it is 
production machines, i cannot change too often.
Kernel is 2.6.24-rc6-git11
Some sysctl adjustments done. Please tell me if need more information.


There is rules in iptables (if it is interesting)
Chain PREROUTING (policy ACCEPT 209M packets, 19G bytes)
 pkts bytes target     prot opt in     out     source               
destination
    0     0 DROP       tcp  --  eth+   *       0.0.0.0/0            0.0.0.0/
0           tcp dpt:1

Chain POSTROUTING (policy ACCEPT 120M packets, 7408M bytes)
 pkts bytes target     prot opt in     out     source               
destination

Chain OUTPUT (policy ACCEPT 18240 packets, 22M bytes)
 pkts bytes target     prot opt in     out     source               
destination
<< some local networks skipped, not important, similar ACCEPT as next >>
 200K  245M ACCEPT     all  --  *      *       0.0.0.0/0            
172.16.0.0/16
3930K  236M REDIRECT   tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/
0           tcp flags:0x17/0x02 TOS match 0x04 redir ports 2
 112M 6720M REDIRECT   tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/
0           tcp dpt:80 flags:0x17/0x02 redir ports 1
 116K 6953K REDIRECT   tcp  --  *      eth0    0.0.0.0/0            0.0.0.0/
0           OWNER UID match 101 tcp flags:0x17/0x02 redir ports 1


[9561199.893090] WARNING: at net/ipv4/tcp_input.c:2391 tcp_fastretrans_alert()
[9561199.893161] Pid: 32283, comm: squid Not tainted 2.6.24-rc6-git11-build-
0020 #9
[9561199.893277]  [<c0294c0b>] tcp_ack+0xd32/0x18cc
[9561199.893398]  [<f89a25d2>] ipt_do_table+0x416/0x474 [ip_tables]
[9561199.893479]  [<c0297efd>] tcp_rcv_established+0xca/0x7ad
[9561199.893566]  [<c029d690>] tcp_v4_do_rcv+0x2b/0x330
[9561199.893636]  [<f89e5659>] nf_ct_deliver_cached_events+0x3e/0x90 
[nf_conntrack]
[9561199.893759]  [<c029f8d1>] tcp_v4_rcv+0x7c4/0x80f
[9561199.893862]  [<c0286fa7>] ip_local_deliver_finish+0xd9/0x148
[9561199.893932]  [<c0286eaf>] ip_rcv_finish+0x2bb/0x2da
[9561199.894004]  [<c02872d1>] ip_rcv+0x1fc/0x237
[9561199.894063]  [<c0286bf4>] ip_rcv_finish+0x0/0x2da
[9561199.894122]  [<c02870d5>] ip_rcv+0x0/0x237
[9561199.894183]  [<c026c90f>] netif_receive_skb+0x376/0x3e2
[9561199.894273]  [<f89055ca>] e1000_clean_rx_irq+0x379/0x445 [e1000]
[9561199.894388]  [<f8905251>] e1000_clean_rx_irq+0x0/0x445 [e1000]
[9561199.894462]  [<f89041c2>] e1000_clean+0x67/0x1f8 [e1000]
[9561199.894547]  [<c026e7e5>] net_rx_action+0x8d/0x17c
[9561199.894632]  [<c012699e>] __do_softirq+0x5d/0xc1
[9561199.894698]  [<c0126a34>] do_softirq+0x32/0x36
[9561199.894755]  [<c0126c86>] irq_exit+0x38/0x6b
[9561199.894813]  [<c01074d1>] do_IRQ+0x5c/0x73
[9561199.894867]  [<c015be46>] sys_read+0x5f/0x67
[9561199.894936]  [<c010575b>] common_interrupt+0x23/0x28
[9561199.895040]  =======================
                                                                                                                    

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

