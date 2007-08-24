From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Problem with implementation of TCP_DEFER_ACCEPT?
Date: Fri, 24 Aug 2007 12:40:48 +0400
Message-ID: <20070824084048.GA8346@ms2.inr.ac.ru>
References: <1187914105.26866.41.camel@bagoas.tjworld.net> <20070824071530.GB26447@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: TJ <linux@tjworld.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54157 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1760879AbXHXJOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 05:14:04 -0400
Content-Disposition: inline
In-Reply-To: <20070824071530.GB26447@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> > At present with TCP_DEFER_ACCEPT the kernel treats the RFC 793 handshake
> > as invalid; dropping the ACK from the client without replying so the
> > client doesn't know the server has in fact set it's internal ACKed flag.
> > 
> > If the client doesn't send a packet containing data before the SYN_ACK
> > time-outs finally expire the connection will be dropped.
> 
> A brought this up a long, long time ago, and I seem to remember
> Alexey Kuznetsov explained me at the time that this was intentional.

Obviously, I said something like "it is exactly what TCP_DEFER_ACCEPT does".


There is no protocol violation here, ACK from client is considered as lost,
it is quite normal and happens all the time. Handshake is not complete,
server remains in SYN-RECV state and continues to retransmit SYN-ACK.
If client tried to cheat and is not going to send its request,
connection will time out.

Alexey

