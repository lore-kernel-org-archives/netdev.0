From: Ben Greear <greearb@candelatech.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Tue, 17 Sep 2002 09:43:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D875BA9.70501@candelatech.com>
References: <Pine.GSO.4.30.0209170608510.1371-100000@shell.cyberus.ca>
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
> On Mon, 16 Sep 2002, Ben Greear wrote:
> 
> 
>>Also, I notice lots of out-of-order packets on a single gigE link when running at high
>>speeds (SMP machine), so the kernel is still having to reorder quite a few packets.
>>Has anyone done any tests to see how much worse it is with dual-port bonding?
> 
> 
> It will depend on the scheduling algorithm used.
> Always remember that reordering is BAD for TCP and you shall be fine.
> Typical for TCP you want to run a single flow onto a single NIC.
> If you are running some UDP type control app in a cluster environment
> where ordering is a non-issue then you could maximize throughput
> by sending as fast as you can on all interfaces.
> 
> 
>>NAPI helps my problem, but does not make it go away entirely.
>>
> 
> 
> Could you be more specific as to where you see reordering with NAPI?
> Please dont disappear. What us it that you see that makes you believe
> theres reordering with NAPI i.edescribe your test setup etc.

I have a program that sends and receives UDP packets with 32-bit sequence
numbers.  I can detect OOO packets if they fit into the last 10 packets
received.  If they are farther out of order than that, the code treats
them as dropped....

I used smp_afinity to tie a NIC to a CPU, and the napi patch for 2.4.20-pre7.

When sending and receiving 250Mbps of UDP/IP traffic (sending over cross-over
cable to other NIC on same machine), I see the occasional OOO packet.  I also
see bogus dropped packets, which means sometimes the order is off by 10 or more
packets....

The other fun thing about this setup is that after running around 65 billion bytes
with this test,
the machine crashes with an OOPs.  I can repeat this at will, but so far only on
this dual-proc machine, and only using the e1000 driver (NAPI or regular).  Soon, I'll
test with a 4-port tulip NIC to see if I can take the e1000 out of the equation...

I can also repeat the at slower speeds (50Mbps send & recieve), and using
the pktgen tool.  If anyone else is running high sustained SEND & RECEIVE traffic,
I would be interested to know their stability!

I have had a single-proc machine running the exact same (SMP) kernel as the dual-proc
machine, but using the tulip driver, and it has run solid for 2 days, sending &
receiving over 1.3 trillion bytes :)

Thanks,
Ben




> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
