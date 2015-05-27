From: David Miller <davem@davemloft.net>
Subject: Re: Looking for a lost patch
Date: Wed, 27 May 2015 11:46:03 -0400 (EDT)
Message-ID: <20150527.114603.897841724165037352.davem@davemloft.net>
References: <20150520063223.GM8928@secunet.com>
	<20150521.172524.1057695410816294973.davem@davemloft.net>
	<20150527083514.GB27342@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbE0PqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 11:46:07 -0400
In-Reply-To: <20150527083514.GB27342@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 27 May 2015 10:35:16 +0200

> We currently check if a socket is attached to a skb and do socket
> error notification in this case, otherwise we do PMTU discovery if
> the packet is too big. Looks like this socket check is not sufficient
> if the packet is already transmitted through a tunnel device.
> 
> I wonder if we have something to know that a packet was already
> transmitted through a tunnel device. We could switch from socket
> notification to PMTU discovery in this case.

Generally speaking, we should not be orphaning the socket as it
traverses through tunnels.

In fact we have taken great pains to avoid doing this.

See, for example, commits:

7026b1ddb6b8d4e6ee33dc2bd06c0ca8746fa7ab
aad88724c9d54acb1a9737cb6069d8470fa85f74
b0270e91014dabfceaf37f5b40ad51bbf21a1302

Therefore what we always should do is retain the original socket
ownership on the SKB, and layers that implement tunneling using
sockets should pass the socket pointer through their output path(s)
and never use skb->sk for this.
