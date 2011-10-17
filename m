From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Mon, 17 Oct 2011 09:47:44 -0700
Message-ID: <4E9C5C30.1040804@hp.com>
References: <1318576791.2533.99.camel@edumazet-laptop> <20111014.034224.1197576516015404466.davem@davemloft.net> <4E985A3F.5080103@hp.com> <4E98B3B4.20406@hp.com> <1318660775.2525.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:31460 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab1JQQrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 12:47:46 -0400
In-Reply-To: <1318660775.2525.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Rick, could you redo the test, using following bit on receiver :
>
> echo 1>/proc/sys/net/ipv4/tcp_adv_win_scale


raj@tardy:~/netperf2_trunk$ netstat -s > before; src/netperf -H 
raj-8510w.americas.hpqcorp.net -t tcp_rr -- -b 256 -D -o 
throughput,local_transport_retrans,remote_transport_retrans,lss_size_end,rsr_size_end 
; netstat -s > afterMIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 
(0.0.0.0) port 0 AF_INET to internal-host.americas.hpqcorp.net 
(16.89.245.115) port 0 AF_INET : nodelay : first burst 256
Throughput,Local Transport Retransmissions,Remote Transport 
Retransmissions,Local Send Socket Size Final,Remote Recv Socket Size Final
78527.68,289,0,16384,98304

Deltas on the receiver:

TcpExt:
     27 packets pruned from receive queue because of socket buffer overrun
     0 TCP sockets finished time wait in fast timer
     0 delayed acks sent
     0 delayed acks further delayed because of locked socket
     Quick ack mode was activated 0 times
     19 packets directly queued to recvmsg prequeue.
     0 bytes directly in process context from backlog
     670 bytes directly received in process context from prequeue
     739983 packet headers predicted
     14 packets header predicted and directly queued to user
     127 acknowledgments not containing data payload received
     235774 predicted acknowledgments
     0 other TCP timeouts
     6553 packets collapsed in receive queue due to low socket buffer
     0 DSACKs sent for old packets
     TCPBacklogDrop: 294

So, moving on to:

> If you still have collapses/retransmits, you then could try :
>
> echo -2>/proc/sys/net/ipv4/tcp_adv_win_scale

raj@tardy:~/netperf2_trunk$ netstat -s > before; src/netperf -H 
raj-8510w.americas.hpqcorp.net -t tcp_rr -- -b 256 -D -o 
throughput,local_transport_retrans,remote_transport_retrans,lss_size_end,rsr_size_end 
; netstat -s > after
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to internal-host.americas.hpqcorp.net (16.89.245.115) port 0 AF_INET : 
nodelay : first burst 256
Throughput,Local Transport Retransmissions,Remote Transport 
Retransmissions,Local Send Socket Size Final,Remote Recv Socket Size Final
95981.83,0,0,121200,156600

No retransmissions in that one.

rick
