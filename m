From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] sk_buff's allocated from private pools
Date: Thu, 20 Mar 2003 10:33:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15993.35552.587283.291895@robur.slu.se>
References: <200303192208.h2JM8Yx1037110@bubba.precisionio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Archie Cobbs <archie@precisionio.com>
In-Reply-To: <200303192208.h2JM8Yx1037110@bubba.precisionio.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Archie Cobbs writes:
 > Hello,
 > 
 > I'm submitting this patch for inclusion in the Linux kernel if deemed
 > generally useful.
 > 
 > The purpose of this patch is to add a new function called alloc_skb_custom()
 > (or whatever) that allows the data portion of an sk_buff to reside in any
 > memory region, not just a region returned by kmalloc(). For example, if a
 > networking device has a restriction on where receive buffers may reside,
 > then the device driver can avoid copying every incoming packet if it is
 > able to create an sk_buff that points to the receive buffer memory.
 > 
 > Basically this amounts to adding a 'free_data' function pointer to the
 > sk_buff structure. By default this points to kfree() but in general could
 > point to anywhere.

 FYI.

 The skb recycling patches I play with uses the same callback and has an 
 implementation for private buffers and sync's with outstanding callback 
 marked skb's etc.

ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/recycle19.pat
ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/e1000-RC-030217.pat

 Also for SMP it marks in skb header in which cpu skb_headerinit was done
 so callback has a chance to re-route skb to the origin CPU to minimize cache
 bouncing in case of recycling. Also skb_headerinit is moved to be the first 
 operation the a skb life of skb not last.

 Current implementation uses only kmalloc for data part so your alloc_skb_custom 
 add some new value.


 Cheers.
						--ro 
