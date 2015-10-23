From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Fri, 23 Oct 2015 15:20:35 +0200
Message-ID: <201510231320.t9NDKZv9017488@room101.nl.oracle.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk> <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26991 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbJWNgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:36:41 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9NDaeWd019148
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 13:36:40 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t9NDNmm0021371
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 13:36:40 GMT
In-Reply-To: <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>Yet another POSIX deficiency.
>
>When a server deals with 10,000,000+ socks, we absolutely do not care of
>this requirement.
>
>O(log(n)) is still crazy if it involves O(log(n)) cache misses.

You miss the fire point of the algorithm; you *always* find an available 
file descriptor in O(log(N)) (where N is the size of the table).

Does your algorithm guarantee that?

>> Is it a problem that you can "hide" your listening socket with a thread in 
>> accept()?  I would think so (It would be visible in netstat but you can't 
>> easily find out why has it)
>
>Again, netstat -p on a server with 10,000,000 sockets never completes.

This point was not about a 10M sockets server but in general...

>Never try this unless you are desperate and want to avoid a reboot
>maybe.
>
>If you absolutely want to nuke a listener because of untrusted
>applications, we better implement a proper syscall.
>
>Android has such a facility.

Solaris has had such an option too, but that wasn't the point.  You really 
don't want to know which application is doing this?

>Alternative would be to extend netlink (ss command from iproute2
>package) to carry one pid per socket.
>
>ss -atnp state listening

That would be an option too.

Casper
