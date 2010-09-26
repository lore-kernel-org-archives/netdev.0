From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 01:25:30 +0200
Message-ID: <20100926232530.GK12373@1wt.eu>
References: <20100926223448.GF12373@1wt.eu> <20100926.153832.115943505.davem@davemloft.net> <20100926225440.GH12373@1wt.eu> <20100926.160838.246540910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45708 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757979Ab0IZXZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 19:25:34 -0400
Content-Disposition: inline
In-Reply-To: <20100926.160838.246540910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 04:08:38PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 27 Sep 2010 00:54:40 +0200
> 
> > On Sun, Sep 26, 2010 at 03:38:32PM -0700, David Miller wrote:
> >> From: Willy Tarreau <w@1wt.eu>
> >> Date: Mon, 27 Sep 2010 00:34:48 +0200
> >> 
> >> > I don't see what is being violated nor what reliability has been
> >> > compromised.
> >> 
> >> The TCP protcol's obligation to reliably deliver data between
> >> two applications, that is what has been violated.
> > 
> > Once again, I don't see why, due to the orphans mechanism. Please
> > consider for a minute that the application-level close() is distinct
> > from the protocol-level close. The application-level close() just
> > instructs the lower layer to turn the connection into an orphan.
> 
> A close() is equivalent to a shutdown() with both the send and
> receive masks set.
> 
> You are telling TCP that you expect no more data to be received.

Agreed. But that's not a reason for killing outgoing data that is
being sent when there are some data left in the rcv buffer.

Honnestly David, after some thinking, could you still find a valid use
of the orphans as they are now ? I personally fail to do so. And what
drove me to the kernel on this issue is that I found the behaviour
inconsistent with the principle of the orphan itself.

Willy

