From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 15:31:04 -0800 (PST)
Message-ID: <20090113.153104.72134741.davem@davemloft.net>
References: <20090108.135515.85489589.davem@davemloft.net>
	<4966F2F4.9080901@cosmosbay.com>
	<49677074.5090802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@zeus.com, w@1wt.eu, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759858AbZAMXbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:31:04 -0500
In-Reply-To: <49677074.5090802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 09 Jan 2009 16:42:44 +0100

> David, if you referred to code at line 1374 of net/ipv4/tcp.c, I
> believe there is no issue with it. We really want to break from this
> loop if !timeo .

Correct, I agree, and I gave some detailed analysis of this in
another response :-)

> Willy patch makes splice() behaving like tcp_recvmsg(), but we might call
> tcp_cleanup_rbuf() several times, with copied=1460 (for each frame processed)

"Like", sure, but not the same since splice() lacks the low-water
and backlog checks.

> I wonder if the right fix should be done in tcp_read_sock() : this is the
> one who should eat several skbs IMHO, if we want optimal ACK generation.
> 
> We break out of its loop at line 1246
> 
> if (!desc->count) /* this test is always true */
> 	break;
> 
> (__tcp_splice_read() set count to 0, right before calling tcp_read_sock())
> 
> So code at line 1246 (tcp_read_sock()) seems wrong, or pessimistic at least.

Yes, that's very odd.
