From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 16:15:33 +0000
Message-ID: <56324625.9000803@oracle.com>
References: <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <20151024023054.GZ22011@ZenIV.linux.org.uk> <201510270908.t9R9873a001683@room101.nl.oracle.com> <562F577E.6000901@oracle.com> <20151029145847.GA10859@netbsd.org> <563238D0.2040802@oracle.com> <20151029160131.GA18961@netbsd.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: David Holland <dholland-tech@netbsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26094 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964920AbbJ2QPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 12:15:46 -0400
In-Reply-To: <20151029160131.GA18961@netbsd.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/10/2015 16:01, David Holland wrote:

> Hardly; it moves the burden of doing stupid things to the
> application. If as you said the goal is to shut down all threads
> cleanly, then it doesn't need to keep track in detail anyway; it can
> just post SIGTERM to every thread, or SIGUSR1 if SIGTERM is bad for
> some reason, or whatever.

I agree that the root issue is poor application design, but posting a 
signal to every thread is not a solution if you only want to shut down a 
subset of threads.

> close(2) as specified by POSIX doesn't prohibit this weird revoke-like
> behavior, but there's nothing in there that mandates it either. (I
> thought this discussion had already clarified that.)

There was an attempt to interpret POSIX that way, with which I still 
disagree. If a FD is closed or reassigned then any current pending 
operations on it should be terminated.

> Note that while NetBSD apparently supports this behavior because
> someone copied it from Solaris, I'm about to go recommend it be
> removed.

Which behaviour? The abort accept() on close() behaviour?

-- 
Alan Burlison
--
