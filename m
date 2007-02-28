From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 14:55:27 +0100
Message-ID: <200702281455.27720.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <45E585AD.8050704@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: John <linux.kernel@free.fr>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <45E585AD.8050704@free.fr>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 February 2007 14:37, John wrote:
> John wrote:
> > I know it's possible to have Linux timestamp incoming datagrams as soon
> > as they are received, then for one to retrieve this timestamp later with
> > an ioctl command or a recvmsg call.
>
> Has it ever been proposed to modify struct skb_timeval to hold
> nanosecond stamps instead of just microsecond stamps? Then make the
> improved precision somehow available to user space.

John, 

Most modern NICS are able to delay packet delivery, in order to reduce number 
of interrupts and benefit from better cache hits.

tg3 for example are able to delay up to 1024 us.

Then kernel is not realtime and some delays can occur between the hardware 
interrupt and the very moment we timestamp the packet. If CPU caches are 
cold, even the instruction fetches could easily add some us.

Enabling nanosecond stamps would be a lie to users, because real accuracy is 
not nanosecond, but in the order of 10 us (at least)

If you depend on a < 50 us precision, then linux might be the wrong OS for 
your application. Or maybe you need a NIC that is able to provide a timestamp 
in the packet itself (well... along with the packet...) , so that kernel 
latencies are not a problem.

Eric
