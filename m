From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 15:18:40 +0000
Message-ID: <563238D0.2040802@oracle.com>
References: <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <20151024023054.GZ22011@ZenIV.linux.org.uk> <201510270908.t9R9873a001683@room101.nl.oracle.com> <562F577E.6000901@oracle.com> <20151029145847.GA10859@netbsd.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: David Holland <dholland-tech@netbsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27327 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756820AbbJ2PSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:18:55 -0400
In-Reply-To: <20151029145847.GA10859@netbsd.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/10/2015 14:58, David Holland wrote:

> ISTM that the best way to do this is to post a signal to the thread so
> accept bails with EINTR, at which point it can check to see if it's
> supposed to be exiting.

Yes, you could use pthread_kill, but that would require keeping a list 
of the tids of all the threads that were using the FD, and that really 
just moves the problem elsewhere rather than fixing it.

> Otherwise it sounds like the call you're looking for is not close(2)
> but revoke(2). Last I remember Linux doesn't have revoke because
> there's no way to implement it that isn't a trainwreck.

close(2) as per specified by POSIX works just fine on Solaris, if that 
was the case everywhere then it wouldn't be an issue. And for cases 
where it is necessary to keep the FD assigned because of races, the 
dup2(2) trick works fine as well.

-- 
Alan Burlison
--
