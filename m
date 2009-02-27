From: Greg Lindahl <greg@blekko.com>
Subject: Re: Treason uncloaked / Broken peer again
Date: Fri, 27 Feb 2009 13:22:34 -0800
Message-ID: <20090227212234.GB25573@bx9.net>
References: <20090226085826.GA12498@gondor.apana.org.au> <Pine.LNX.4.64.0902261105030.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:53808 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757532AbZB0VWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 16:22:36 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902261105030.31742@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 11:30:58AM +0200, Ilpo J=E4rvinen wrote:

> Right, it's rather crude to have buggy kernel which sends past the=20
> receiver's advertized window, and then when it cannot cope the result=
s of=20
> its own bug (and prints that message), put a blame on others who beha=
ve in=20
> a compliant way.

Well, perhaps we shouldn't have the message be "Broken peer" when the
problem is often on the node printing the message? Maybe "Something's
broken, might be me"?

One of the people who complained to me is running 2.4.26, so the bug
in TSO that you fixed in 2.6.25 is not the last bug at issue. I was
also able to turn off TSO on all my 2.6.18+redhat systems and quickly
got Treason, so this bug is not the only one. But still, I can't cause
the bug often enough to get a tcpdump of it in action.

-- greg

=46ixed in 2.6.25:

commit 5ea3a7480606cef06321cd85bc5113c72d2c7c68
Author: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Date:   Tue Mar 11 17:55:27 2008 -0700

    [TCP]: Prevent sending past receiver window with TSO (at last skb)

    With TSO it was possible to send past the receiver window when the =
skb
    to be sent was the last in the write queue while the receiver windo=
w
    is the limiting factor. One can notice that there's a loophole in t=
he
    tcp_mss_split_point that lacked a receiver window check for the
    tcp_write_queue_tail() if also cwnd was smaller than the full skb.

    Noticed by Thomas Gleixner <tglx@linutronix.de> in form of "Treason
    uncloaked! Peer ... shrinks window .... Repaired."  messages (the p=
eer
    didn't actually shrink its window as the message suggests, we had j=
ust
    sent something past it without a permission to do so).

