From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Mon, 12 Jan 2009 00:08:24 +0100
Message-ID: <20090111230824.GB10848@outpost.ds9a.nl>
References: <20090111212303.GA8612@outpost.ds9a.nl> <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com> <20090111224541.GA10848@outpost.ds9a.nl> <20090111225427.GA7004@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([85.17.220.215]:40091 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958AbZAKXIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 18:08:15 -0500
Content-Disposition: inline
In-Reply-To: <20090111225427.GA7004@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 01:54:27AM +0300, Evgeniy Polyakov wrote:
> You can try to work with tcp cork options, uncorking the socket means
> that stack has sent data to the hardware, there are no other guarantees.

Ah, smart.

> > It appears that if one asks sendfile() to transmit a million bytes, it will
> > only return when the ACK for the millionth byte is in.
> 
> No it is not, it returns when it believes it has sent all the requested
> data, but in practice it can be even not sent but waiting in some
> hardware queue.

Ah ok.

> > I know that TCP will never be fully fully reliable, but I would love to have
> > a way to know that the millionth byte was ACKed, or alternatively, that an
> > error prevented that.
> 
> There is no way to get a notification when data is acked by the remote
> side. Generally you should invent some kind of own explicit acks.

I fully understand. Sometimes I have to talk to stupid devices though. What
I do find is the TCP_INFO ioctl, which offers this field in struct tcp_info:

        __u32   tcpi_unacked;

Which comes from:

struct tcp_sock {
...
        u32     packets_out;    /* Packets which are "in flight"        */
...
}

If this becomes 0, perhaps this might tell me everything I sent was acked?

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
