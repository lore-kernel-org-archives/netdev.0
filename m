From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 09:19:23 -0700
Message-ID: <1445617163.22974.163.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A37A3.8000705@oracle.com>
	 <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A563D.6020600@oracle.com>
	 <1445616011.22974.158.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36339 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbJWQTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 12:19:25 -0400
Received: by pacfv9 with SMTP id fv9so127814370pac.3
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 09:19:24 -0700 (PDT)
In-Reply-To: <1445616011.22974.158.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 09:00 -0700, Eric Dumazet wrote:
> on the pages you think there is an error that matters.
> 
> > 
> > > Have you tested the patch I sent ?
> > 
> > The AF_UNIX poll one? No, I don't have the means to do so, and in any 
> > case that's not a POSIX issue, just a plain bug. I'm happy to log a bug 
> > if that helps.

BTW, there is no kernel bug here. POSIX poll() man page says :

POLLOUT
    Normal data may be written without blocking. 

If you attempt to write on a listener, write() does _not_ block and
returns -1, which seems correct behavior to me, in accordance with man
page.

socket(PF_LOCAL, SOCK_STREAM, 0)        = 3
bind(3, {sa_family=AF_LOCAL, sun_path=@""}, 110) = 0
listen(3, 10)                           = 0
write(3, "test", 4)                     = -1 ENOTCONN (Transport endpoint is not connected)

Could you point out which part of POSIX is mandating that af_unix
listener MUST filter out POLLOUT ?

Thanks.
