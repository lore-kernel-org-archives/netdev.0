From: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
Subject: A question on RTT estimation of SACKed packet.
Date: Thu, 29 Aug 2002 03:17:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <037601c24f45$4549fe10$f1fa010a@weixl>
References: <Pine.GSO.4.30.0206241450330.13908-100000@shell.cyberus.ca> <3D6C6CF6.9040002@candelatech.com> <20020828074112.A13868@nero.doit.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Everyone,
    I am studying the Linux 2.4.19 TCP code. I have a question on the RTT
estimation.
    In the function tcp_clean_rtx_queue (tcp_input.c), all the packet before
snd_una is checked:
    1. When a packet was not SACKed before, we can calculate the seq_rtt
from its skb's timestamp (now - scb->when).
    2. When a packet was SACKed but not retransmitted, the linux also
calculate the seq_rtt from it when there is no unSACKed packet in the queue.
     I cannot understand the second situation: The packet was SACKed before,
that means it arrived the receiver and triggered a SACK sometime before. The
interval between when packet is sent and when the SACK is received should be
the RTT for experienced this packet. Even now the packet is ACKed, I don't
think this ACK is triggered by this packet. Why is it used to calculate the
RTT?
      Thanks.

-David

Xiaoliang (David) Wei             Graduate Student in CS@Caltech
http://www.cs.caltech.edu/~weixl
====================================================
