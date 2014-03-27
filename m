From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Thu, 27 Mar 2014 12:53:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EA7FB@AcuExch.aculab.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<87ha6k7jt7.fsf@sable.mobileactivedefense.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com>
 <87zjkb7r1q.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: 'Rainer Weikusat' <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37473 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753781AbaC0Myr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:54:47 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26192-07 for <netdev@vger.kernel.org>;
 Thu, 27 Mar 2014 12:54:44 +0000 (GMT)
In-Reply-To: <87zjkb7r1q.fsf@sable.mobileactivedefense.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rainer Weikusat 
> Considering all of this, the trylock-approach seems best to me. OTOH,

No - using trylock() is definitely wrong.
If there are two messages queued and two processes/threads try to
read them, you don't want one of them being given EAGAIN.

If we ignore the case where there are some blocking and some
non-blocking readers (which doesn't work for other reasons)
then it would actually make sense for the non-blocking
code to wait uninterruptibly (possibly with a timeout that
should never expire) and for the blocking code to wait
interruptibly (as currently).

Then problem of which error code to return is moot.

	David
