From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 05:01:10 -0700
Message-ID: <1445947270.7476.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5628636E.1020107@oracle.com>
	 <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
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
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33697 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbbJ0MBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 08:01:12 -0400
Received: by pabla5 with SMTP id la5so28065839pab.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 05:01:12 -0700 (PDT)
In-Reply-To: <562F577E.6000901@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-27 at 10:52 +0000, Alan Burlison wrote:

> Unfortunately Hadoop isn't the only thing that pulls the shutdown() 
> trick, so I don't think there's a simple fix for this, as discussed 
> earlier in the thread. Having said that, if close() on Linux also did an 
> implicit shutdown() it would mean that well-written applications that 
> handled the scoping, sharing and reuse of FDs properly could just call 
> close() and have it work the same way across *NIX platforms.


Are non multi threaded applications considered well written ?

listener = socket(...);
bind(listener, ...);
listen(fd, 10000);
Loop 1 10
  if (fork() == 0)
    do_accept(listener)

Now if a child does a close(listener), or is killed, you propose that it
does an implicit shutdown() and all other children no longer can
accept() ?

Surely you did not gave all details on how it is really working.
