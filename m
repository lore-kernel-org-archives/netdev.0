From: David Miller <davem@davemloft.net>
Subject: Re: lowpri - RTO for unidirectional reciever
Date: Mon, 08 Dec 2008 23:56:22 -0800 (PST)
Message-ID: <20081208.235622.149344934.davem@davemloft.net>
References: <493DD199.6080600@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750949AbYLIH4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 02:56:21 -0500
In-Reply-To: <493DD199.6080600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 08 Dec 2008 18:02:01 -0800

> A Mac OSX bug was found/presumed, but there was an interesting
> behaviour on the linux receiver side as well - the rtx of the
> ignored FIN happened after what IIRC is the initial RTO.  It
> suggested that the ACK of the SYN|ACK didn't update the rtt estimate
> or if it did, didn't so so very much.  Bug? Feature?  No idea, but
> food for thought.

We should not use the SYN|ACK for RTT estimates.

It's a bug, and in fact we used to, but I fixed that long
ago.

Since there is no data in the packet, and it's therefore very small
compared to real data bearing packets, the RTT measured might be
artificially small and not really representative.
