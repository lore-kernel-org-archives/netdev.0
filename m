From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 14:36:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99EB40.8030006@nortelnetworks.com>
References: <Pine.GSO.4.30.0210011342370.18461-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, kuznet@ms2.inr.ac.ru,
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
>>
> 
> If you want realibility then thats what TCP is for.

There is a requirement to interwork with other equipment using UDP.

> I am curious why you would even want to retransmit a voice packet or
> why a local drop should be treated any different from a remote/network
> drop in a voice application ...

The legacy app generates batches of messages, and the emulator layer 
then sends them out in a tight loop on sendto().  I don't want packets 
to be silently dropped by the kernel because userspace is sending faster 
than they can get onto the wire during that tight loop.

Eric's original testcase was a tight loop on sendto() resulting in 
userspace sending at a way higher rate than could be put onto the wire, 
so the kernel was silently dropping them.  This is exactly what I want 
to avoid.

> When you fail in sendto/sendmsg, errno is set to ENOBUFS as long as you
> set IP_RECVERR in the socket options; you can also receive ICMP errors
> as described in the manpages (use a msg_control buffer and call recvmsg
> with MSG_ERRQUEUE).

Okay, so with IP_RECVERR set the case that Eric saw will not happen?  I 
mean that sendto() will return with -1 and errno set to ENOBUFS?

> BTW, a good sample of an app that makes good use of ENOBUFS to do
> congestion control, IP_RECVERR and MSG_ERRQUEUE is the ping app in Alexeys
> iputils package. Why did i not remember all this before chasing the
> phantom with Eric is an indication i need to increase my cafeine
> consumption

I'll take a look and try things out.

Chris
