From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO
Date: Thu, 19 May 2005 17:21:07 -0700 (PDT)
Message-ID: <20050519.172107.59468102.davem@davemloft.net>
References: <20050517.192416.108741581.davem@davemloft.net>
	<200505200015.j4K0FNVG005262@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: leonid.grossman@neterion.com
In-Reply-To: <200505200015.j4K0FNVG005262@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Leonid Grossman" <leonid.grossman@neterion.com>
Date: Thu, 19 May 2005 17:15:18 -0700

> A somewhat related thought, while we are at it...
> 
> It would arguably make sense to allow a NIC to set max TSO size that the
> card is 
> willing to support (rather than assume/enforce 64k). Some NICs support
> bigger max 
> TSO size today, but it is even more important to allow a NIC to limit
> TSO to a smaller size.

We can never use a maximum greater than 65535 because that
is the limit of the representation of the ipv4 header length
field.  These TSO packets have to be processed by the entire
IP output path, including things like the firewalling and
packet scheduler modules.

So it must look like a valid IPV4 packet.

> One likely scenario where this feature is desirable is a system with highly
> fragmented memory. 
> In this case, the number of physical fragments per TSO frame could be always
> so high that it will be cheaper 
> (on a given platform) to copy the frame than to DMA it. 

We always chop up the user data into individual system pages when we
build TSO frames, so I can't see how any kind of memory fragmentation
could be an issue.

So this kind of nullifies your argument for smaller TSO size
limits as specified by the card.

The segmenter in the TCP code has the most knowledge about how it
should segment, based upon numerous factors, many if not all of which
the networking card is totally unaware of.
