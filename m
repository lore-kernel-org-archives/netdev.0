From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Mon, 12 Jan 2009 01:54:27 +0300
Message-ID: <20090111225427.GA7004@ioremap.net>
References: <20090111212303.GA8612@outpost.ds9a.nl> <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com> <20090111224541.GA10848@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bert hubert <bert.hubert@netherlabs.nl>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:53491 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbZAKWy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 17:54:29 -0500
Content-Disposition: inline
In-Reply-To: <20090111224541.GA10848@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bert.

On Sun, Jan 11, 2009 at 11:45:43PM +0100, bert hubert (bert.hubert@netherlabs.nl) wrote:
> Is there any way to make sure there is no pending output data, so one can
> safely call close(), and not get an RST-situation? 

You can try to work with tcp cork options, uncorking the socket means
that stack has sent data to the hardware, there are no other guarantees.

> Let me put it more succinctly. What I would very much like to have is what
> Linux sendfile() offers in practice.
> 
> It appears that if one asks sendfile() to transmit a million bytes, it will
> only return when the ACK for the millionth byte is in.

No it is not, it returns when it believes it has sent all the requested
data, but in practice it can be even not sent but waiting in some
hardware queue.

> I know that TCP will never be fully fully reliable, but I would love to have
> a way to know that the millionth byte was ACKed, or alternatively, that an
> error prevented that.

There is no way to get a notification when data is acked by the remote
side. Generally you should invent some kind of own explicit acks.

-- 
	Evgeniy Polyakov
