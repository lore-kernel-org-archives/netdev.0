From: Ben Greear <greearb@candelatech.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Tue, 17 Sep 2002 21:06:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87FBD5.3030508@candelatech.com>
References: <Pine.GSO.4.30.0209172100361.3686-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
   Cacophonix <cacophonix@yahoo.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Tue, 17 Sep 2002, Ben Greear wrote:
> 
> 
>>I have a program that sends and receives UDP packets with 32-bit sequence
>>numbers.  I can detect OOO packets if they fit into the last 10 packets
>>received.  If they are farther out of order than that, the code treats
>>them as dropped....
>>
> 
> 
> So let me understand this:
> You have a packet going out eth0 looped back to eth0 and you are seeing

I go out eth2 and come in eth3, both e1000 copper nics.

> reordering? What sort of things are happening from departure at udp socket
> to arrival on the other side? Are you doing anything funky yourself or
> it is all kernel?

I see reordering on regular old socket calls from user space, and I see
the same thing with pktgen packets as well (which clears the stack of fault).

For user space, I am binding to source IP, setting SO_BINDTODEVICE, and O_NONBLOCK.
Nothing overly weird I believe.

pktgen has its own ways, basically it grabs the pkts in the dev.c receive method
near where the bridging code grabs it's packets...

I see no reordering at all with tulip 4-port nics and single processor machines.

> 
> 
>>I used smp_afinity to tie a NIC to a CPU, and the napi patch for 2.4.20-pre7.
> 
> 
> Did you get reordering with affinity?

Yes.  I'm not sure I tried affinity w/out NAPI though.  I definately tried
it with NAPI and saw reordering.

> 
> 
>>When sending and receiving 250Mbps of UDP/IP traffic (sending over cross-over
>>cable to other NIC on same machine), I see the occasional OOO packet.  I also
>>see bogus dropped packets, which means sometimes the order is off by 10 or more
>>packets....
> 
> 
> A lot of shit is happening at that rate in particular with PCI bus. If
> i understood correctly a packet crosses the bus about 4 times?

Two times I believe, but I'm sending in both directions, so there is about
1Gbps across the bus, not even counting the UDP, IP, and Ethernet headers.

> 
> 
>>The other fun thing about this setup is that after running around 65 billion bytes
>>with this test, the machine crashes with an OOPs.
> 
> 
> No clue whats going on - probably a race somewhere and cant help since
> i dont have this NIC but if you get Robert excited he might be able to
> help you.

He seems moderately interested, suggested I try the one in 2.5.[latest].
I'll be able to do that next week, assuming it's trivial to compile it
for 2.4.19....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
