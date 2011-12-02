From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 00:29:59 +0200
Message-ID: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45744 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598Ab1LBWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 17:30:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi

 Recently i started to get SYN attacks, and managed them.
 syncookies didn't helped, here is "perf report" info:
 -     26.89%        swapper  [kernel.kallsyms]     [k] _raw_spin_lock
    - _raw_spin_lock
       - 94.97% tcp_v4_rcv
            ip_local_deliver_finish
            ip_local_deliver
            ip_rcv_finish
            ip_rcv
            __netif_receive_skb
            process_backlog
            net_rx_action
            __do_softirq
            call_softirq
            do_softirq
          + irq_exit

 But then i got attack that made server to choke and bypassed "--syn" 
 rule, and i was surprised, that stack are handling invalid combination 
 of flags, SYN+FIN.
 Is it valid behaviour?

 in tcp_input.c, tcp_rcv_state_process(), it just does check for rst (to 
 discard), but maybe packet with fin set should be discarded too?

 From http://www.whitehats.ca/main/members/Seeker/seeker_tcp_header/

 SYN FIN is probably the best known illegal combination. Remember that 
 SYN is used to start a connection, while FIN is used to end an existing 
 connection. It is nonsensical to perform both actions at the same time. 
 Many scanning tools use SYN FIN packets, because many intrusion 
 detection systems did not catch these in the past, although most do so 
 now. You can safely assume that any SYN FIN packets you see are 
 malicious.

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
