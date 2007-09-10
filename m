From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Mon, 10 Sep 2007 14:54:43 -0700
Message-ID: <1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>
References: <46E5900A.3010009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:35333 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755219AbXIJV6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 17:58:21 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ALwKjR011712
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 17:58:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ALwK75667878
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 17:58:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ALwJDC031452
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 17:58:19 -0400
In-Reply-To: <46E5900A.3010009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-09-10 at 11:42 -0700, Rick Jones wrote:
> I've been digging around to see about inducing /proc/net/tcp to show 
> some "interesting" things for listen sockets (eg backlog depth, its max, 
> and dropped connection requests).

backlog depth(acceptq length) for a listening socket should be available
with the newer kernels. The following patch exports this value via the rx_queue
field in /proc/net/tcp.
 http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=47da8ee681d04e68ca1b1812c10e28162150d453

>   While there I've noticed that both 
> tcp_v[46]_syn_recv_sock and tcp_v[46]conn_request both check that the 
> listen queue is full, but only tcp_v[46]_syn_recv_sock increments some 
> mib stats for dropped connection requests.
> 
> Is that deliberate, or is that a hole in the stats?

looks like it is a hole in the stats. I think we should increment
LISTENOVERFLOWS or LISTENDROPS in tcp_v[46]_conn_request too if the
SYN is dropped.

Thanks
Sridhar

