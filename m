From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: RE: via-rhine "reset did not complete" errors
Date: Mon, 28 Oct 2002 16:03:25 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <7BFCE5F1EF28D64198522688F5449D5A03C07A@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>, <rl@hellgate.ch>
Return-path: <linux-net-owner@vger.kernel.org>
content-class: urn:content-classes:message
To: "Donald Becker" <becker@scyld.com>
List-Id: netdev.vger.kernel.org

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


