From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 17:55:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.175559.70205743.davem@redhat.com>
References: <20030522.034058.71558626.davem@redhat.com>
	<20030522114438.GD2961@netnation.com>
	<1053608586.9475.60.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: gandalf@wlug.westbo.se
In-Reply-To: <1053608586.9475.60.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Martin Josefsson <gandalf@wlug.westbo.se>
   Date: 22 May 2003 15:03:07 +0200

   On Thu, 2003-05-22 at 13:44, Simon Kirby wrote:
   
   > Nice!  I tested with 300,000 routing table entries and there is no
   > discernable difference in performance from having an empty table. 
   > vmstat shows the same idle time as when the routing table is empty.
   
   How much memory does a table that large use?
   
300,000 * sizeof(struct fib_node)

the second term is:

	(2 * sizeof_pointer_on_this_architecture) + /* 8 or 16 bytes */
	sizeof(u32) + /* 4 bytes */
	4 * sizeof(u8)) /* 4 bytes */

So that's 16 bytes on 32-bit systems, and 24 bytes on 64-bit systems.

Therefore 300,000 routes take up 4.8MB on 32-bit systems and 7.2MB
on 64-bit ones.

I cannot fathom a way to make these any smaller :-)
