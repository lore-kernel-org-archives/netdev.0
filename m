From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 15:13:30 +0000
Message-ID: <87zjkd802t.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:35950 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755043AbaCZPNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:13:44 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	(David Laight's message of "Wed, 26 Mar 2014 15:00:27 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:
> From: Eric Dumazet
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Some applications didn't expect recvmsg() on a non blocking socket
>> could return -EINTR. This possibility was added as a side effect
>> of commit b3ca9b02b00704 ("net: fix multithreaded signal handling in
>> unix recv routines").
>> 
>> To hit this bug, you need to be a bit unlucky, as the u->readlock
>> mutex is usually held for very small periods.
>
> The commit message for b3ca9b02b00704 looks very strange.
> Maybe something else is wrong.
>
> If we assume that u->readlock is only held for a short period
> why should it matter than the kernel decided to give the
> signal to that thread?

(This is from memory) If there's a thread blocked in recv and another
blocked on the lock and the kernel selects the thread blocked on the lock
for handling the signal, the signal won't be handled until some data is
received on the socket, ie, possibly never.
