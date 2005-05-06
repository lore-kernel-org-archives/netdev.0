From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH] TSO Reloaded
Date: Fri, 6 May 2005 07:09:17 -0700
Message-ID: <200505061409.j46E9HVG020066@guinness.s2io.com>
References: <20050505203052.059125eb.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050505203052.059125eb.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David S. Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 05, 2005 8:31 PM
> To: Leonid Grossman
> Cc: netdev@oss.sgi.com
> Subject: Re: [PATCH] TSO Reloaded
> 
> On Thu, 5 May 2005 20:20:56 -0700
> "Leonid Grossman" <leonid.grossman@neterion.com> wrote:
> 
> > We will be testing on 10GbE NICs in the next couple weeks; will let you
> > know.
> > BTW - any plans for IPv6 support?
> 
> What exactly does your NIC expect?  Do you use the
> NETIF_F_HW_CSUM flag to indicate generic checksumming support?
> Otherwise, there is no other way to support ipv6 checksum offload
> at the moment, and that is a requirement for ipv6 TSO.
> 
> For TSO, the ipv6 header handling seems very non-trivial.
> What is supposed to happen in cases where certain optional
> extension headers should be present in some of the frames
> but not the others?

Our ASIC supports ipv6 CSUM and TSO (and header splitting) even if extension
headers are present, but I suspect the majority ipv6-capable NICs will not
implement this; the stack needs to query NIC header-processing capabilities
(for both CSUM and TSO) and act accordingly.

> 
> A specification of how your NIC support ipv6 TSO is necessary
> in order for support to be written, see?  

We are planning to release the ASIC programming manual to the community
fairly soon, this will provide a better view on IPv6 LSO and some other
features.

>Seems like you are
> the most qualified person to write the support, therefore :-)
> Really, it isn't that hard and you have something on which
> to test whatever you write, whereas I don't.

We will probably get to it sometime down the road; at the moment support for
UDP LSO and receive side offloads are much higher on our list. 

Getting a vanilla (no support for extension headers) implementation from
someone who knows the stack better than we do would be a good thing :-), I
suspect this should be useful for more than one NIC vendor.

Leonid
