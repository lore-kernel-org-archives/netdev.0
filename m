From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH] Super TSO
Date: Thu, 19 May 2005 17:36:25 -0700
Message-ID: <200505200036.j4K0aVVG008391@guinness.s2io.com>
References: <20050519.172107.59468102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S.Miller'" <davem@davemloft.net>
In-Reply-To: <20050519.172107.59468102.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: David S.Miller [mailto:davem@davemloft.net] 
> Sent: Thursday, May 19, 2005 5:21 PM
> To: leonid.grossman@neterion.com
> Cc: netdev@oss.sgi.com
> Subject: Re: [PATCH] Super TSO
> 
> From: "Leonid Grossman" <leonid.grossman@neterion.com>
> Date: Thu, 19 May 2005 17:15:18 -0700
> 
> > A somewhat related thought, while we are at it...
> > 
> > It would arguably make sense to allow a NIC to set max TSO 
> size that 
> > the card is willing to support (rather than assume/enforce 
> 64k). Some 
> > NICs support bigger max TSO size today, but it is even more 
> important 
> > to allow a NIC to limit TSO to a smaller size.
> 
> We can never use a maximum greater than 65535 because that is 
> the limit of the representation of the ipv4 header length 
> field.  These TSO packets have to be processed by the entire 
> IP output path, including things like the firewalling and 
> packet scheduler modules.
> 
> So it must look like a valid IPV4 packet.
> 
> > One likely scenario where this feature is desirable is a 
> system with 
> > highly fragmented memory.
> > In this case, the number of physical fragments per TSO 
> frame could be 
> > always so high that it will be cheaper (on a given 
> platform) to copy 
> > the frame than to DMA it.
> 
> We always chop up the user data into individual system pages 
> when we build TSO frames, so I can't see how any kind of 
> memory fragmentation could be an issue.

This is exactly what I wanted to hear :-)
If the TSO implementation guarantees that the payload comes (for the most
part) 
in physically continuous pages, then the number of fragments 
will never get out of whack, and my argument indeed becomes invalid.

> 
> So this kind of nullifies your argument for smaller TSO size 
> limits as specified by the card.
> 
> The segmenter in the TCP code has the most knowledge about 
> how it should segment, based upon numerous factors, many if 
> not all of which the networking card is totally unaware of.

Sure. On the other hand, the TCP code is unaware of the copy vs. DMA costs
on a particular NIC 
(well, this is actually more specific to a system than to a NIC). 
But I guess as long as both the packet size and the number of fragments will
not get very big at the same time,
A NIC will be OK.


> 
