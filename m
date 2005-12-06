From: Marc Singer <elf@buici.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 5 Dec 2005 21:18:22 -0800
Message-ID: <20051206051822.GC6820@buici.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu> <4394C3D4.9050909@unfix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>,
	Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jeroen Massar <jeroen@unfix.org>
Content-Disposition: inline
In-Reply-To: <4394C3D4.9050909@unfix.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 11:48:52PM +0100, Jeroen Massar wrote:
> John Heffner wrote:
> > Jeroen Massar wrote:
> >> I wonder how many RFC's it violates. An interface must only answer ARP's
> >> on the interface that it is configured on, not anything else.
> > 
> > Not true.  See RFC 1122, section 3.3.4.  The standard leaves this
> > decision up to the implementation, for good reason.
> 
> RFC1122 is a document about multicast. ARP is broadcast see the very old
>  RFC826/STD0037. Multicast didn't even work on much of the hardware from
> the times that that document was written.
> 
> Probably the best text about this subject can be found in RFC1027:
> 8<-----------
> 2.4  Sanity checks
> 
>     Care must be taken by the network and gateway administrators to keep
>     the network masks the same on all the subnet gateway machines.  The
>     most common error is to set the network mask on a host without a
>     subnet implementation to include the subnet number.  This causes the
>     host to fail to attempt to send packets to hosts not on its local
>     subnet.  Adjusting its routing tables will not help, since it will
>     not know how to route to subnets.
> 
>     If the IP networks of the source and target hosts of an ARP request
>     are different, an ARP subnet gateway implementation should not
>     reply.  This is to prevent the ARP subnet gateway from being used to
>     reach foreign IP networks and thus possibly bypass security checks
>     provided by IP gateways.
> -------------->8
> 
> Which is almost the same as what I noted. Note that the document is
> about Proxy ARP, when a host is responding ARP queries for an IP on a
> different link, this is exactly what it is doing: proxy arp.

Interesting, but I don't think it applies.  We're talking about
reaching the node, not about using the node as a transparent gateway.
Note the part about "an ARP subnet gateway implementation" that need
to be careful.

> 
> > This topic has been discussed many times on a variety of mailing lists.
> >  I think the best way to do this is to make the behavior configurable,
> > which Linux currently does.
> 
> As long as the default is off I am fine with it, people turning it on
> themselves break their own network :)

Indeed.  Safety (sanity) first.
