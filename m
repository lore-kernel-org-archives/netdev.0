From: Richard Underwood <richard@aspectgroup.co.uk>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 17:54:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <353568DCBAE06148B70767C1B1A93E625EAB5B@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: willy@w.ods.org, alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
   lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@redhat.com>,
   Stephan von Krawczynski
	 <skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 
> It means that systems (like Linux) that make IP addresses owned by the
> host instead of specific interfaces cannot correctly interoperate with
> such remote systems.
> 
	This makes sense for replies, but not for requests.

	When a HOST sends out an ARP request, it's NOT associated with a
single connection, it's associated with the host. Why should it pick a
"random" IP number to send as the source address?

	The way the network code is currently, you're reducing your
connectivity to chance. There should be a defined process for making a
connection to another host. As it stands, this process is simply not
predictable.

	If you insist that an ARP request IS directly associated with a
connection, then you are required to have one ARP cache per source IP
address. It'd be predictable again ... but I don't think anyone wants to go
there.

> It is also the case that a host cannot possibly be aware of all
> subnets present on a given LAN, therefore is should be liberal in it's
> replies to ARP requests.
> 
	Well, actually, I know exactly which IP subnets are on which LAN
segments - they're defined by the IP address and subnet of the interface. I
think you'll find that this a pretty basic feature of most hosts.

> Finally, it violates the most basic rule of IP networking:
> 
> "Be liberal in what you accept, and conservative in what you send"
> -Jon Postel
> 
	I'm sorry, but Linux simply isn't being conservative in what it
sends. It's being bloody awkward.

	Look at it this way - when a host sends out an ARP request, it WANTS
a reply, it's not doing it for fun. If it uses the IP number of the
interface it's sending the ARP request on, it will ALWAYS get a reply
(assuming there's one to get.) If it uses the IP number of another
interface, it MAY get a reply, but it MAY NOT.

	Are there any cases when this is reversed? I don't think so! Linux
is being intentionally difficult, and as far as I can tell, for no good
reason.

> In general, when a host posses the information necessary to allow
> other hosts to communicate, it should provide that information
> whenever possible.
> 
	No, it should follow the rules for letting traffic pass through it.
Just because a host can see two networks, doesn't mean it should route
between them - it possesses information, but there have to be rules to
determine how this information is used.

	Compare it to IP: If a firewall sees a packet come in on an
interface it shouldn't, it'll probably drop it - it's called anti-spoofing.
Should the firewall forward the packet on just because it can?

	So at the lower layer, a router sees an ARP packet with what looks
like a "spoofed" source address. Should it trust it implicitly and place it
in its cache, or should it drop it?

	No one yet has given one single example of a network that relies on
Linux's current behaviour. I've given two examples of networks that break
because of it. I would kindly suggest that the default should be changed.

	Thanks,

		Richard
