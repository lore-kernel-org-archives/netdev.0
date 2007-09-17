From: Rick Jones <rick.jones2@hp.com>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Mon, 17 Sep 2007 11:13:05 -0700
Message-ID: <46EEC3B1.4@hp.com>
References: <46E5900A.3010009@hp.com> <20070914.201034.38702610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:53338 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbXIQSNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 14:13:36 -0400
In-Reply-To: <20070914.201034.38702610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 10 Sep 2007 11:42:18 -0700
> 
> 
>>I've been digging around to see about inducing /proc/net/tcp to show 
>>some "interesting" things for listen sockets (eg backlog depth, its max, 
>>and dropped connection requests).  While there I've noticed that both 
>>tcp_v[46]_syn_recv_sock and tcp_v[46]conn_request both check that the 
>>listen queue is full, but only tcp_v[46]_syn_recv_sock increments some 
>>mib stats for dropped connection requests.
> 
> 
> They are checking two different things.
> 
> tcp_v{4,6}_conn_request is checking whether we are hitting the limit
> for allowing the initial SYN and creating a new embryonic mini-socket.
> Exceeding that is not a listen overflow.

I'll risk some toe chewing and ask - is the embryonic limit set based on 
  what one sets in the listen() call and/or system configs?

Seems that _some_ sort of stat should be incremented, even if it isn't 
the listen queue overflow one?

rick jones

> tcp_v{4,6}_syn_recv_sock() is processing the end of the 3-way
> handshake and wants to create a full established state socket to queue
> into the listening parent.  This is checking the listening socket
> queue limits, and indeed is a listen queue overflow if exceeded.


