From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 11:52:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99EED2.7020301@candelatech.com>
References: <Pine.GSO.4.30.0210011342370.18461-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, Chris Friesen <cfriesen@nortelnetworks.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Tue, 1 Oct 2002, Ben Greear wrote:
> 
> 
>>get my pktgen and send-to-self code cleaned up, I am planning to start
>>working on making UDP reliably send packets, or return an error to
>>the calling code.  I will, of course, keep you informed if I actually
>>get something working...
> 
> 
> If you want realibility then thats what TCP is for.
> I am curious why you would even want to retransmit a voice packet or
> why a local drop should be treated any different from a remote/network
> drop in a voice application ...

Don't worry so much about why I want to do this, just assume that I do! :)
I have explained in the past, but since our needs are different, it does
not seem to impress upon anyone (I want to send at high speeds, and detect
every possible packet dropped by the network.  If my local machine drops
the packet, my detection of network-dropped packets is bogus...)

The reason a local packet drop is different, is because it can be different.
Any feedback of this nature that we can give to user-space can be used to
make any recovery or throttling decisions better.  I accept that I cannot
guarantee a UDP packet is received by it's intended target, but I do not
accept that the local machine cannot even guarantee that it has sent the
packet onto the network.

> 
> When you fail in sendto/sendmsg, errno is set to ENOBUFS as long as you
> set IP_RECVERR in the socket options; you can also receive ICMP errors
> as described in the manpages (use a msg_control buffer and call recvmsg
> with MSG_ERRQUEUE).

I will investigate the IP_RECVERR more closely, it may do just what I need.

Thanks,
Ben

> 
> BTW, a good sample of an app that makes good use of ENOBUFS to do
> congestion control, IP_RECVERR and MSG_ERRQUEUE is the ping app in Alexeys
> iputils package. Why did i not remember all this before chasing the
> phantom with Eric is an indication i need to increase my cafeine
> consumption.
> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
