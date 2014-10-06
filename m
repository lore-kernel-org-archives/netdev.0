From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: handle association restarts when the socket is
 closed.
Date: Mon, 6 Oct 2014 11:09:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174AC1DA@AcuExch.aculab.com>
References: <1412374580-22286-1-git-send-email-vyasevich@gmail.com>
 <20141006.002229.1370132762577292096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"vyasevich@gmail.com" <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53085 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751289AbaJFLLR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:11:17 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31156-08 for <netdev@vger.kernel.org>;
 Mon,  6 Oct 2014 12:11:05 +0100 (BST)
In-Reply-To: <20141006.002229.1370132762577292096.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Fri,  3 Oct 2014 18:16:20 -0400
> 
> > From: Vlad Yasevich <vyasevich@gmail.com>
> >
> > Currently association restarts do not take into consideration the
> > state of the socket.  When a restart happens, the current assocation
> > simply transitions into established state.  This creates a condition
> > where a remote system, through a the restart procedure, may create a
> > local association that is no way reachable by user.  The conditions
> > to trigger this are as follows:
> >   1) Remote does not acknoledge some data causing data to remain
> >      outstanding.
> >   2) Local application calls close() on the socket.  Since data
> >      is still outstanding, the association is placed in SHUTDOWN_PENDING
> >      state.  However, the socket is closed.
> >   3) The remote tries to create a new association, triggering a restart
> >      on the local system.  The association moves from SHUTDOWN_PENDING
> >      to ESTABLISHED.  At this point, it is no longer reachable by
> >      any socket on the local system.
> >
> > This patch addresses the above situation by moving the newly ESTABLISHED
> > association into SHUTDOWN-SENT state and bundling a SHUTDOWN after
> > the COOKIE-ACK chunk.  This way, the restarted associate immidiately
> > enters the shutdown procedure and forces the termination of the
> > unreachable association.
> >
> > Reported-by: David Laight <David.Laight@aculab.com>
> > Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> 
> Applied, thanks.
> 
> Candidate for -stable?

Maybe, but while I raised the problem and tested the fix, I added
a workaround to our M3UA code to ABORT sctp connections.
I'll predicate it on a kernel version when I know which one it is in,
but I'm not going to check backports to old distributions.
(I'm tempted to disable sctp on 2.6.18 kernels...)

So I'm not worried -stable.

Other sctp users may be more worried.

	David
