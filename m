From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 23:53:26 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030819235326.2920dacf.skraw@ithnet.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	<1061320099.30567.55.camel@dhcp23.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: richard@aspectgroup.co.uk, davem@redhat.com, willy@w.ods.org,
	carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
	bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1061320099.30567.55.camel@dhcp23.swansea.linux.org.uk>
List-Id: netdev.vger.kernel.org

On 19 Aug 2003 20:08:20 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > 	But if I was to do this in the other direction (arp -d 172.20.240.1;
> > ping -I 172.24.0.1 172.20.240.1) then I'd lose connectivity over my default
> > route because 172.20.240.1 won't accept ARP packets from IP numbers not on
> > the connected subnet. The <incomplete> ARP entry will block any further ARP
> > requests from valid IP numbers.
> 
> One thing I agree with you about is that an ARP resolution for an
> address via one path should not block a resolution for it by another
> path since to begin with the two paths may be to different routers
> one of which is down.

Sounds logical.

Can you explain to me why there should be a difference in the source ip of an
arp request originated by an ip packet from another address of the same host
compared to a forwarded packet from another host, coming in on some secondary
interface?
If I understood David correctly the first case will do an arp request with
source ip equal to source ip of the packet (originated locally).
In the second case (the box has to forward some foreign packet) for sure its
interface address will be used, correct? Or does that read: _some_ interface
address will be used?
Why this difference? The destination host cannot distinguish between these two
cases, so they can be as well handled just the same. But it seems obvious that
a foreign IP cannot be used as a source for an arp request.
And overall, looking at an arp table, what is visible is: interface, MAC and
corresponding IP. So as soon as an arp request is successfully completed the
box doesn't even remember the source ip of the former arp request, right?

Regards,
Stephan
