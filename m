From: =?iso-8859-2?Q?Zaccomer_Lajos?= <zacco@fw.hu>
Subject: =?iso-8859-2?Q?many_sockets,_slow_sendto?=
Date: Tue, 06 Mar 2007 16:08:38 +0100
Message-ID: <E1HObHK-0000WB-00@osiris.swi.hu>
Reply-To: =?iso-8859-2?Q?Zaccomer_Lajos?= <zacco@fw.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mystic.root.hu ([193.202.82.14]:56712 "EHLO mystic.root.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965157AbXCFPi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 10:38:58 -0500
Received: from osiris.swi.hu ([193.202.82.16])
	by mystic.root.hu with esmtp (Exim 4.63 #1 (Debian))
	id 1HOb89-0002aB-56
	for <netdev@vger.kernel.org>; Tue, 06 Mar 2007 15:59:09 +0100
Received: from www-data by osiris.swi.hu with local (Exim 3.36 #1 (Debian))
	id 1HObHK-0000WB-00
	for <netdev@vger.kernel.org>; Tue, 06 Mar 2007 16:08:38 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,



I'm playing around with a simulation, in which many thousands of IP

addresses (on interface aliases) are used to send/receive TCP/UDP

packets. I noticed that the time of send/sendto increased linearly

with the number of file descriptors, and I found it rather strange.
I

searched for some related topics, but I couldn't find any (I might

have chosen the wrong keywords).

Though, I'm a real kernelnewbie, I made up my mind to follow what is

happening in the deep. I used the printk and do_gettimeofday

functions to print timestamps at certain points of the execution
path

to identify the bottleneck. Each socket is bound to a dedicated IP

address and each socket is using the very same port number, with the

help of SO_REUSEADDR socket option. I use the 2.16.19-r5

gentoo-sources on my Compaq Evo N1020v laptop. So far, I could get
to

the following point:



=46unction/macro: Location:

sys_send net/socket.c

sys_sendto net/socket.c

sock_sendmsg net/socket.c

__sock_sendmsg net/socket.c

(*socket_sendmsg)=3Dinet_sendmsg net/ipv4/af_inet.c

(*sendmsg)=3Dudp_sendmsg net/ipv4/udp.c

udp_push_pending_frames net/ipv4/udp.c

ip_push_pending_frames net/ipv4/ip_output.c

NF_HOOK include/linux/netfilter.h

ip_output net/ipv4/ip_output.c

ip_finish_output net/ipv4/ip_output.c

ip_finish_output2 net/ipv4/ip_output.c

dst->heighbour->output=3Ddev_queue_xmit net/core/dev.c

rcu_read_unlock_bh include/linux/rcupdate.c

local_bh_enable kernel/softirq.c



At this point, I felt really helpless, and I don't even know if I'm

at the right track in this investigation. So, can someone please

help me with advice or links pointing to the info I need? Let me
know

if you need any further input.



I expect that sending a packet should not depend on the number of

file descriptors (sockets), it should be a more or less constant
time

operation. Can you confirm this, or is there something in the kernel

or elsewhere preventing it?



Any hints are welcome. Thanks a lot!

/Zacco=20




_____________________________________________________________________
 50Mbyte kereskedelmi webt=E1rhely + korl=E1tlan sz=E1m=FA e-mail + php=
 + sql
       havi 1,365 Ft-=E9rt!  B=F5vebben:  http://www.swi.hu
 =20
