From: Eric Lemoine <Eric.Lemoine@Sun.COM>
Subject: Re: simple change to qdisc_restart()
Date: Tue, 20 May 2003 13:24:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520112402.GF978@udine>
References: <20030520082217.GC978@udine>
 <20030520.012824.85398613.davem@redhat.com> <20030520085724.GD978@udine>
 <16074.1339.3673.938923@robur.slu.se> <20030520112109.GE978@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <20030520112109.GE978@udine>
To: Eric Lemoine <Eric.Lemoine@Sun.COM>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Let me explain a bit more.
> 
> I developped a kernel module that basically implements per-cpu kernel
> threads, each being bound to a particular cpu. I also modified the
> Myrinet NIC driver and firmware so that they implement per-cpu rx rings.
> 
> The NIC makes sure that packets of the same connection are always
> deposited in the same ring. Here's how it does it. For each incoming
> pkt, the NIC computes the index of the ring into which the packet must
> be placed [*], passes this index to the driver, and dmas the packet into
> the appropriate ring. The driver uses the ring index to wake up the
> appropriate kernel thread. Each kernel-thread behaves in a NAPI manner.

Oops. I forgot to mention that:

[*] Currently the NIC simply does ring_idx = IPsrc & (nr_rings-1).

-- 
Eric
