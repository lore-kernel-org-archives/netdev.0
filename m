From: jamal <hadi@cyberus.ca>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Tue, 17 Sep 2002 21:07:53 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209172100361.3686-100000@shell.cyberus.ca>
References: <3D875BA9.70501@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
   Cacophonix <cacophonix@yahoo.com>, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D875BA9.70501@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 17 Sep 2002, Ben Greear wrote:

> I have a program that sends and receives UDP packets with 32-bit sequence
> numbers.  I can detect OOO packets if they fit into the last 10 packets
> received.  If they are farther out of order than that, the code treats
> them as dropped....
>

So let me understand this:
You have a packet going out eth0 looped back to eth0 and you are seeing
reordering? What sort of things are happening from departure at udp socket
to arrival on the other side? Are you doing anything funky yourself or
it is all kernel?

> I used smp_afinity to tie a NIC to a CPU, and the napi patch for 2.4.20-pre7.

Did you get reordering with affinity?

>
> When sending and receiving 250Mbps of UDP/IP traffic (sending over cross-over
> cable to other NIC on same machine), I see the occasional OOO packet.  I also
> see bogus dropped packets, which means sometimes the order is off by 10 or more
> packets....

A lot of shit is happening at that rate in particular with PCI bus. If
i understood correctly a packet crosses the bus about 4 times?

>
> The other fun thing about this setup is that after running around 65 billion bytes
> with this test, the machine crashes with an OOPs.

No clue whats going on - probably a race somewhere and cant help since
i dont have this NIC but if you get Robert excited he might be able to
help you.

> I can repeat this at will, but so far only on
> this dual-proc machine, and only using the e1000 driver (NAPI or regular).  Soon, I'll
> test with a 4-port tulip NIC to see if I can take the e1000 out of the equation...
>

I doubt youll see it there.

cheers,
jamal
