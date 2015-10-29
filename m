From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 17:07:48 +0000
Message-ID: <20151029170748.GG22011@ZenIV.linux.org.uk>
References: <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com>
 <20151029145847.GA10859@netbsd.org>
 <563238D0.2040802@oracle.com>
 <20151029160131.GA18961@netbsd.org>
 <56324625.9000803@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Holland <dholland-tech@netbsd.org>, Casper.Dik@oracle.com,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36171 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbbJ2RH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 13:07:56 -0400
Content-Disposition: inline
In-Reply-To: <56324625.9000803@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 04:15:33PM +0000, Alan Burlison wrote:

> There was an attempt to interpret POSIX that way, with which I still
> disagree. If a FD is closed or reassigned then any current pending
> operations on it should be terminated.

Could the esteemed sir possibly be ars^H^H^Hprevailed upon to quote the exact
place in POSIX that requires such behaviour?

This is getting ridiculous - if we are talking about POSIX-mandated behaviour
of close(), please show where is it mandated.  Using close(2) on a descriptor
that might be used by other threads is a bloody bad design in userland code -
I think everyone in this thread agrees on that.  Making that a recommended way
to do _anything_ is nuts.

Now, no userland code, however lousy it might be, should be able to screw
the system.  But that isn't the issue - our variant is providing that just
fine.

BTW, "cancel accept(2) because sending a signal is hard" is bogus anyway -
a thread in accept(3) just about to enter the kernel would get buggered
if another thread closes that descriptor and the third one does socket(2).
_IF_ you are doing that kind of "close a descriptor under other threads"
thing, you need to inform the potentially affected threads anyway, and
you'd better not rely on them being currently in kernel mode.
