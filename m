From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: RE: via-rhine "reset did not complete" errors
Date: Mon, 28 Oct 2002 17:38:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7BFCE5F1EF28D64198522688F5449D5A03C07C@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>, <rl@hellgate.ch>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>,
   "Donald Becker" <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More info/possible solution:

I remembered the Via linuxfet driver and dug it up.
The linuxfet close routine does acknowledge some
problems and does some special casing and action when
the recvr does not turn off in a certain amount of time.

I put that code in the our via-rhine driver and my
'ifconfig eth0 down; ifconfig eth0 up; ping -c2 xxxx; sleep 2;'
loop has been running for about 20 minutes. Without changes
it usually took less than a minute for "fail".

larry


-----Original Message-----
From: Larry Sendlosky 
Sent: Monday, October 28, 2002 4:20 PM
To: Larry Sendlosky; Donald Becker
Cc: linux-net@vger.kernel.org; netdev@oss.sgi.com; rl@hellgate.ch
Subject: RE: via-rhine "reset did not complete" errors


Oop, litte red-faced here....basically, I can't count.

When the 'stop' routine does issue a stop cmd,
the "bad" status of CR0 is 0xc (not 0xE as my mind
read it). The "start" bit is not on after the "stop".
Just the recvr and stop bits. A subsequent reset issued by
the 'start' routine will not complete when in this state.

sorry for the mind fart...

larry

-----Original Message-----
From: Larry Sendlosky 
Sent: Monday, October 28, 2002 4:03 PM
To: Donald Becker
Cc: linux-net@vger.kernel.org; netdev@oss.sgi.com; rl@hellgate.ch
Subject: RE: via-rhine "reset did not complete" errors


Hi Donald,

Thanks for the reply.

The "reset timeout" happens on the initial reset in the 'open'
routine. The reset bit (bit 7 of CR1) is not clearing after
being written.  This usually happens after the 'close' routine
(on a previous 'ifconfig eth0 down') writes the stop cmd to CR0
and the "start" bit is still on after writing the stop cmd to CR0.

What is the proper way to "stop" this little beast? 

thanks again,

larry 

-----Original Message-----
From: Donald Becker [mailto:becker@scyld.com]
Sent: Monday, October 28, 2002 2:38 PM
To: Larry Sendlosky
Cc: linux-net@vger.kernel.org; netdev@oss.sgi.com; rl@hellgate.ch
Subject: Re: via-rhine "reset did not complete" errors


On Mon, 28 Oct 2002, Larry Sendlosky wrote:

> We're using VIA EPIA mini-ITX with 800Mhz C3 and the
> VT6103 PHY. (via-rhine driver says VT6102). We have made sure
> power supply is "big enough". Our kernel is 2.4.18 with
> via-rhine.c patches to fix TX timeout.

Those are evil patches...

> Our TX timeout issues seem to have gone away with the recent
> patches. However we are still plagued with the "reset did not
> complete in 10ms" errors.

A driver _really_, _really_ shouldn't be busy-waiting for link
negotiation to complete.  That happened a lot with MS-DOS drivers, but
it wasn't even reasonable there.
Yet it's far easier for someone to get a horribly flawed patch like that
accepted, while my patches went completely ignored.


> Once it this state, a warm restart of
> the system is necessary (and we have seen this problem at
> boot time, which is more confusing).

Look at the what the code is doing.  It is easier to write drivers when
you make the rest of the kernel single threaded on your code...

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
