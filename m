From: David Miller <davem@davemloft.net>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Fri, 14 Sep 2007 20:10:34 -0700 (PDT)
Message-ID: <20070914.201034.38702610.davem@davemloft.net>
References: <46E5900A.3010009@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:57387
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753109AbXIODKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 23:10:37 -0400
In-Reply-To: <46E5900A.3010009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 10 Sep 2007 11:42:18 -0700

> I've been digging around to see about inducing /proc/net/tcp to show 
> some "interesting" things for listen sockets (eg backlog depth, its max, 
> and dropped connection requests).  While there I've noticed that both 
> tcp_v[46]_syn_recv_sock and tcp_v[46]conn_request both check that the 
> listen queue is full, but only tcp_v[46]_syn_recv_sock increments some 
> mib stats for dropped connection requests.

They are checking two different things.

tcp_v{4,6}_conn_request is checking whether we are hitting the limit
for allowing the initial SYN and creating a new embryonic mini-socket.
Exceeding that is not a listen overflow.

tcp_v{4,6}_syn_recv_sock() is processing the end of the 3-way
handshake and wants to create a full established state socket to queue
into the listening parent.  This is checking the listening socket
queue limits, and indeed is a listen queue overflow if exceeded.
