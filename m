From: David Holland <dholland-tech@netbsd.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 30 Oct 2015 05:44:18 +0000
Message-ID: <20151030054418.GA16702@netbsd.org>
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
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netbsd.org ([149.20.53.66]:61403 "EHLO mail.netbsd.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbbJ3FoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 01:44:20 -0400
Content-Disposition: inline
In-Reply-To: <56324625.9000803@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 04:15:33PM +0000, Alan Burlison wrote:
 > >close(2) as specified by POSIX doesn't prohibit this weird revoke-like
 > >behavior, but there's nothing in there that mandates it either. (I
 > >thought this discussion had already clarified that.)
 > 
 > There was an attempt to interpret POSIX that way, with which I still
 > disagree. If a FD is closed or reassigned then any current pending
 > operations on it should be terminated.

C&V, please.

 > >Note that while NetBSD apparently supports this behavior because
 > >someone copied it from Solaris, I'm about to go recommend it be
 > >removed.
 > 
 > Which behaviour? The abort accept() on close() behaviour?

That, and aborting anything else too. Close isn't revoke.

-- 
David A. Holland
dholland@netbsd.org
