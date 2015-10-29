From: David Holland <dholland-tech@netbsd.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 14:58:47 +0000
Message-ID: <20151029145847.GA10859@netbsd.org>
References: <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
 <20151022172146.GS22011@ZenIV.linux.org.uk>
 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
 <20151022190701.GV22011@ZenIV.linux.org.uk>
 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netbsd.org ([149.20.53.66]:62324 "EHLO mail.netbsd.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965046AbbJ2O6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 10:58:49 -0400
Content-Disposition: inline
In-Reply-To: <562F577E.6000901@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 10:52:46AM +0000, Alan Burlison wrote:
 > >But in general, this is basically a problem with the application: the file
 > >descriptor space is shared between threads and having one thread sniping
 > >at open files, you do have a problem and whatever the kernel does in that
 > >case perhaps doesn't matter all that much: the application needs to be
 > >fixed anyway.
 > 
 > The scenario in Hadoop is that the FD is being used by a thread that's
 > waiting in accept and another thread wants to shut it down, e.g. because
 > the application is terminating and needs to stop all threads cleanly.

ISTM that the best way to do this is to post a signal to the thread so
accept bails with EINTR, at which point it can check to see if it's
supposed to be exiting.

Otherwise it sounds like the call you're looking for is not close(2)
but revoke(2). Last I remember Linux doesn't have revoke because
there's no way to implement it that isn't a trainwreck.

-- 
David A. Holland
dholland@netbsd.org
