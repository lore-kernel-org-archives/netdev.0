From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 08:18:06 +0200
Message-ID: <20091016061806.GD5574@1wt.eu>
References: <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <4AD7EDB4.7060907@gmail.com> <4AD7FE01.1010805@gmail.com> <20091016052913.GB5574@1wt.eu> <4AD80D1F.3090601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50276 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbZJPGSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:18:52 -0400
Content-Disposition: inline
In-Reply-To: <4AD80D1F.3090601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2009 at 08:05:19AM +0200, Eric Dumazet wrote:
> > Couldn't we just rely on the retrans vs rskq_defer_accept comparison ?
> > 
> 
> In this case, we lose TCP_DEFER_ACCEPT advantage in case one SYN-ACK was dropped
> by the network : We wakeup the listening server when first ACK comes from client,
> instead of really wait the request.
> 
> I think being able to count pure-acks would be slighly better, and cost nothing.
> 
> 
> retrans is the number of SYN-RECV (re)sent, while req_acks would count number of
> pure ACK received.
> 
> Those numbers, in an ideal world should be related, but could differ in real world ?

Yes it could differ if a pure ACK is lost between the client and the server,
but in my opinion what is important is not to precisely account the number
of ACKs to ensure we wake up exactly after XXX ACKs received, but that in
most common situations we avoid to wake up too early.

Also, keep in mind that the TCP_DEFER_ACCEPT parameter is passed in number
of seconds by the application, which are in turn converted to a number of
retransmits based on our own timer, which means that our SYN-ACK counter
is what most closely matches the application's expected delay, even if an
ACK from the client gets lost in between or if a client's stack retransmits
pure ACKs very fast for any implementation-specific reason.

Regards,
Willy

