From: Juliusz Chroboczek <jch@pps.jussieu.fr>
Subject: Re: Asserting ECN from userspace?
Date: Thu, 13 Oct 2011 13:30:21 +0200
Message-ID: <7izkh5m8mq.fsf@lanthane.pps.jussieu.fr>
References: <4E8BF6B2.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
To: David =?iso-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:62407 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985Ab1JMLr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 07:47:27 -0400
In-Reply-To: <4E8BF6B2.6030101@gmail.com> ("David =?iso-8859-1?Q?T=E4ht=22?=
 =?iso-8859-1?Q?'s?= message of "Tue, 04
	Oct 2011 23:18:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I'm not sure what you are getting at.  ECN is designed for routers, not
for end-points.  Assering ECN congestion-experienced at the sender will
cause the sender to react to the congestion indication after a whole RTT
(after the ECN-echo is received).  For end-to-end flow control, it is
both simpler and more efficient to reduce the sending rate immediately,
without going over the network.

There's a good reason why we're careful to distinguish congestion
control (router-to-endpoint) and flow control (endpoint-to-endpoint).
The latter is much easier.

> 1) Applications such as bittorrent (transmission, etc) that are much
> more aware of their overall environment could assert ECN on their UDP
> streams to indicate congestion.

The sender can react to congestion by simply reducing the sending rate.
The receiver can react to congestion by pipelining fewer chunk requests
to the sender.

> 3) Web Proxies. A web proxy could note when it was experiencing
> congestion on one side of the proxied connection (or another) and signal
> the other side to slow down.

It can cause the other side to slow down by simply stopping reading,
thus causing the normal TCP flow control (not congestion control) to
kick in.

What would be useful, on the other hand, would be the ability to set the
ECN enabled codepoint on UDP packets, and have some means to reliably
check whether the Congestion-Experienced codepoint has been set by some
intermediate router.  But that's different from what you appear to be
suggesting.

-- Juliusz
