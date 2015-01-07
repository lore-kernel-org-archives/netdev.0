From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Wed, 07 Jan 2015 11:45:02 +0100
Message-ID: <1420627502.26870.38.camel@redhat.com>
References: <5487DD65.60800@gtsys.com.hk> <549AC2B4.8070203@gtsys.com.hk>
	 <1420560073.32369.60.camel@redhat.com> <20150107072254.GA13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Ruehl <chris.ruehl@gtsys.com.hk>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbbAGKpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 05:45:16 -0500
In-Reply-To: <20150107072254.GA13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2015-01-07 at 08:22 +0100, Steffen Klassert wrote:
> On Tue, Jan 06, 2015 at 05:01:13PM +0100, Hannes Frederic Sowa wrote:
> > 
> > xfrm6_output_finish unconditionally resets skb->protocol so we try to
> > dispatch to the IPv6 handler, even though tcp just sends an IPv4 packet.
> 
> Maybe we better dispatch based on sk->sk_family, this should give
> always the right address family of the socket.

The original problem was dealing with IPv4/v6 mapped traffic. Processing
local errors from unconnected UDP sockets which are emitting both IPv4
and IPv6 frames won't play nicely with sk->sk_family I fear.

Bye,
Hannes
