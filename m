From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFCv4 PATCH 0/2] net: Introduce recvmmsg socket syscall
Date: Wed, 16 Sep 2009 14:07:33 -0300
Message-ID: <20090916170733.GB7699@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nir Tzachar <nir.tzachar@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbZIPRIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 13:08:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	Nir, can you please test with this patchset and check if latency
numbers improved? They should, I think :-)

	New perf callgraphs here:

http://oops.ghostprotocols.net:81/acme/perf.recvmsg.step2.cg.data.txt.bz2

versus

http://oops.ghostprotocols.net:81/acme/perf.recvmmsg.step2.cg.data.txt.bz2

	Look at what appears now on the radar, its not locking :-)
	
	Or course, I need to do more tests, but it looks promising, please give
it a go and report back here if you can!

- Arnaldo

# Samples: 761074
#
# Overhead   Command             Shared Object  Symbol
# ........  ........  ........................  ......
#
     6.54%  recvmmsg  [kernel]                  [k] skb_set_owner_r
                |
                |--99.43%-- sock_queue_rcv_skb
                |          __udp_queue_rcv_skb
                |          sk_backlog_rcv
                |          release_sock
                |          __sys_recvmmsg
                |          sys_recvmmsg
                |          system_call_fastpath
                |          syscall
                |          |
                |           --12.76%-- main
                |                     __libc_start_main
                |
                 --0.57%-- __udp_queue_rcv_skb
                           sk_backlog_rcv
                           release_sock
                           __sys_recvmmsg
                           sys_recvmmsg
                           system_call_fastpath
                           syscall
                           |
                            --10.84%-- main
                                      __libc_start_main

     5.88%  recvmmsg  [kernel]                  [k] _spin_lock_irqsave
                |
                |--47.58%-- skb_queue_tail
                |          sock_queue_rcv_skb
                |          __udp_queue_rcv_skb
                |          sk_backlog_rcv
                |          release_sock
                |          __sys_recvmmsg
                |          sys_recvmmsg
                |          system_call_fastpath
                |          syscall
                |          |
                |           --12.56%-- main
                |                     __libc_start_main
                |
                |--41.85%-- __skb_recv_datagram
                |          __udp_recvmsg
                |          udp_unlocked_recvmsg
                |          sock_common_unlocked_recvmsg
                |          __sock_unlocked_recvmsg_nosec
                |          |
                |          |--98.41%-- sock_unlocked_recvmsg_nosec
                |          |          __sys_recvmsg
                |          |          __sys_recvmmsg
                |          |          sys_recvmmsg
                |          |          system_call_fastpath
                |          |          syscall
                |          |          |
                |          |           --12.82%-- main
                |          |                     __libc_start_main
                |          |
                |           --1.59%-- sock_unlocked_recvmsg
                |                     __sys_recvmsg
                |                     __sys_recvmmsg
                |                     sys_recvmmsg


- Arnaldo
