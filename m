From: Rick Jones <rick.jones2@hp.com>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Mon, 10 Sep 2007 15:22:55 -0700
Message-ID: <46E5C3BF.7020605@hp.com>
References: <46E5900A.3010009@hp.com> <1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:46725 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761964AbXIJWX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 18:23:28 -0400
In-Reply-To: <1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> On Mon, 2007-09-10 at 11:42 -0700, Rick Jones wrote:
> 
>>I've been digging around to see about inducing /proc/net/tcp to show 
>>some "interesting" things for listen sockets (eg backlog depth, its max, 
>>and dropped connection requests).
> 
> 
> backlog depth(acceptq length) for a listening socket should be available
> with the newer kernels. The following patch exports this value via the rx_queue
> field in /proc/net/tcp.
>  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=47da8ee681d04e68ca1b1812c10e28162150d453

Yep, I see it in the 2.6.23-rc5 tree I'm using.  At the risk of yet 
another "merely practice" patching excercise I'm putting together a 
patch which will also return that in a TCP_INFO and add the max backlog 
(to the tx_queue field)

While doing that, I've noticed that 
Documenation/networking/proc-net-tcp.txt (?) talks about a tcp6_get_info 
which I cannot find anywhere in the tree.  I'm not sure if that simply 
means that tcp_get_info is what is used for a "tcp6" connection and the 
text can simply be removed from the documentation, or if it is called 
something else.

>>  While there I've noticed that both 
>>tcp_v[46]_syn_recv_sock and tcp_v[46]conn_request both check that the 
>>listen queue is full, but only tcp_v[46]_syn_recv_sock increments some 
>>mib stats for dropped connection requests.
>>
>>Is that deliberate, or is that a hole in the stats?
> 
> 
> looks like it is a hole in the stats. I think we should increment
> LISTENOVERFLOWS or LISTENDROPS in tcp_v[46]_conn_request too if the
> SYN is dropped.

OK.  Now, can we get a third to Sridhar's second?-)

rick jones
struggling through the maze of twisty routines for connection establishment

