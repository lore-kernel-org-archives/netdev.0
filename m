From: "David S. Miller" <davem@davemloft.net>
Subject: Re: prequeue still a good idea?
Date: Thu, 28 Apr 2005 11:52:00 -0700
Message-ID: <20050428115200.353db06c.davem@davemloft.net>
References: <c0a09e5c05042811492162746@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Grover <andy.grover@gmail.com>
In-Reply-To: <c0a09e5c05042811492162746@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Apr 2005 11:49:32 -0700
Andrew Grover <andy.grover@gmail.com> wrote:

> /* Packet is added to VJ-style prequeue for processing in process
>  * context, if a reader task is waiting. Apparently, this exciting
>  * idea (VJ's mail "Re: query about TCP header on tcp-ip" of 07 Sep 93)
>  * failed somewhere. Latency? Burstiness? Well, at least now we will
>  * see, why it failed. 8)8)				  --ANK
>  */
> 
> I'm trying to understand -- is the prequeue really not a win, and if
> so, why do we still have it?
> 
> Especially with modern tcp csumming HW, its benefit is not clear to
> me. The whole point of the prequeue, and calling tcp_v4_do_rcv from
> user context, was to speed up *sw* csum, right?

It's not about the checksum only, it's about _scheduling_.

Let's say that we can get a process to wake up every quantum X,
which means that with prequeue the processes arrival rate of X onto the
cpu will determine the pacing of the data sinking and thus the ACKs
on the TCP connection.

That is, the TCP data rate becomes paced to the rate at which the
system can handle the current load.  It creates a very stable system.

Without prequeue, we ACK immediately.  This artificially makes the sender
believe that it can pump data out at that rate to the receiver.

People who want ultra-low latency hate this, which is why we have a
way to shut it off via sysctl so the cluster and distributed computing
folks can get the behavior they want.
