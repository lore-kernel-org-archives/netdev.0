From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Looking for a lost patch
Date: Thu, 28 May 2015 07:51:52 +0200
Message-ID: <20150528055150.GG27342@secunet.com>
References: <20150520063223.GM8928@secunet.com>
 <20150521.172524.1057695410816294973.davem@davemloft.net>
 <20150527083514.GB27342@secunet.com>
 <20150527.114603.897841724165037352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <alexander.h.duyck@redhat.com>, <alexander.duyck@gmail.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49119 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbbE1FwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 01:52:00 -0400
Content-Disposition: inline
In-Reply-To: <20150527.114603.897841724165037352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 11:46:03AM -0400, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 27 May 2015 10:35:16 +0200
> 
> > We currently check if a socket is attached to a skb and do socket
> > error notification in this case, otherwise we do PMTU discovery if
> > the packet is too big. Looks like this socket check is not sufficient
> > if the packet is already transmitted through a tunnel device.
> > 
> > I wonder if we have something to know that a packet was already
> > transmitted through a tunnel device. We could switch from socket
> > notification to PMTU discovery in this case.
> 
> Generally speaking, we should not be orphaning the socket as it
> traverses through tunnels.
> 
> In fact we have taken great pains to avoid doing this.

Yes, I'm aware of this. I don't want to orphan the socket,
all I wanted to do is to change the way we notify about MTU
changes. I.e. use icmpv6_send() instead of xfrm_local_error()
if the packet traversed a tunnel, that's why I wondered whether
we can know this.
