From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 13:55:24 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210011342370.18461-100000@shell.cyberus.ca>
References: <3D99D061.1090208@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <kuznet@ms2.inr.ac.ru>, Chris Friesen <cfriesen@nortelnetworks.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D99D061.1090208@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 1 Oct 2002, Ben Greear wrote:

> get my pktgen and send-to-self code cleaned up, I am planning to start
> working on making UDP reliably send packets, or return an error to
> the calling code.  I will, of course, keep you informed if I actually
> get something working...

If you want realibility then thats what TCP is for.
I am curious why you would even want to retransmit a voice packet or
why a local drop should be treated any different from a remote/network
drop in a voice application ...

When you fail in sendto/sendmsg, errno is set to ENOBUFS as long as you
set IP_RECVERR in the socket options; you can also receive ICMP errors
as described in the manpages (use a msg_control buffer and call recvmsg
with MSG_ERRQUEUE).

BTW, a good sample of an app that makes good use of ENOBUFS to do
congestion control, IP_RECVERR and MSG_ERRQUEUE is the ping app in Alexeys
iputils package. Why did i not remember all this before chasing the
phantom with Eric is an indication i need to increase my cafeine
consumption.

cheers,
jamal
