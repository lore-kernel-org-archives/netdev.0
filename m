From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 30 Oct 2015 17:43:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBC66C8@AcuExch.aculab.com>
References: <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
 <20151022172146.GS22011@ZenIV.linux.org.uk>
 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
 <20151022190701.GV22011@ZenIV.linux.org.uk>
 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com> <20151029145847.GA10859@netbsd.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Casper.Dik@oracle.com" <Casper.Dik@oracle.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Holland' <dholland-tech@netbsd.org>,
	Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:63767 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbJ3Ro0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 13:44:26 -0400
In-Reply-To: <20151029145847.GA10859@netbsd.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Holland
> Sent: 29 October 2015 14:59
> On Tue, Oct 27, 2015 at 10:52:46AM +0000, Alan Burlison wrote:
>  > >But in general, this is basically a problem with the application: the file
>  > >descriptor space is shared between threads and having one thread sniping
>  > >at open files, you do have a problem and whatever the kernel does in that
>  > >case perhaps doesn't matter all that much: the application needs to be
>  > >fixed anyway.
>  >
>  > The scenario in Hadoop is that the FD is being used by a thread that's
>  > waiting in accept and another thread wants to shut it down, e.g. because
>  > the application is terminating and needs to stop all threads cleanly.
> 
> ISTM that the best way to do this is to post a signal to the thread so
> accept bails with EINTR, at which point it can check to see if it's
> supposed to be exiting.

Actually, just send it a connect indication.

ISTM that the correct call should be listen(fd, 0);
Although that doesn't help a thread stuck in recvmsg() for a datagram.

It is also tempting to think that close(fd) should sleep until all
io activities using that fd have completed - whether or not blocking
calls are woken.

	David
