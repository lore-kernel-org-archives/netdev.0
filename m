From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: simple change to qdisc_restart()
Date: Tue, 20 May 2003 14:24:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16074.7787.988583.56689@robur.slu.se>
References: <20030520082217.GC978@udine>
	<20030520.012824.85398613.davem@redhat.com>
	<20030520085724.GD978@udine>
	<16074.1339.3673.938923@robur.slu.se>
	<20030520112109.GE978@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@Sun.COM>
In-Reply-To: <20030520112109.GE978@udine>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Eric Lemoine writes:

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

 OK! 
 Sounds interesting...
 So reordering should be guaranteed within "connections" but not per interface.

 And if you can repeat the trick with per-cpu rings for tx you can eventually  
 eliminate cache bouncing when sending/freeing skb's.

 We tried to tag with cpu-owner in tx-ring when doing hard_xmit and having same
 cpu sending it to do kfree but the complexity balanced the win... The thinking
 was that per-cpu tx rings could help.

 Cheers.
						--ro
