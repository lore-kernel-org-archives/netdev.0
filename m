From: Andre Tomt <andre@tomt.net>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Tue, 01 Mar 2005 22:50:25 +0100
Message-ID: <4224E3A1.5090003@tomt.net>
References: <200502270928.44402.Info@Quantum-Sci.com> <422205F7.4080401@tomt.net> <200502271220.06560.Info@quantum-sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Quantum Scientific <Info@quantum-sci.com>
In-Reply-To: <200502271220.06560.Info@quantum-sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quantum Scientific wrote:
> On Sunday 27 February 2005 11:40, Andre Tomt wrote:
>>You seem to be fixed on the idea that a ipv6 stack has to have stateful 
>>firewalling, or else its utter crap, correct? :-)
> 
> 
> No, I'll try to say this clearer.
> 
> The stack works fine in.  And out.  But for a useful virtual circuit you must 
> have something like connection tracking.
> 
> Remember what my issue is:  
> - I have a very tight firewall,
> - I ping6 out,
> - The firewall blocks the reply back, because the connection is stateless!

Never, ever, filter ICMP. Or at least be extremely careful doing so. You 
may end up breaking things like PMTU and error notification mechanisms.

> - Same with http, etc.
> 
> This means that I have to open for incoming, virtually every port I send 
> outgoing to, or else I do not get any replies. This is what I call 
> non-functional, because one does not open incoming ports, for the most part.
> 
> Why are you not having this problem?

Because I tend to use the oldskool way of doing it when there is not 
other option, by matching on SYN. It's a bit trickier with UDP, but 
doable for most UDP based protocols.

Also on a per-system basis I tend to prefer to secure services rather 
than firewall them; by for example just shutting them off/uninstalling 
them if not used, binding to localhost, use tcpwrappers.. that sort of 
thing.

Don't get me wrong; I'd *love* to see connection tracking integrated 
with ipv6 netfilter. It would simplify some of my setups greatly. But it 
would also be out of the question on a lot of my other setups; as 
connection tracking is a *severe* bottleneck when faced with any real 
amounts of load.

It's not The universal solution, and the lack of it is not *that* bad.

>>Connection tracking is on the way, currently a implementation exists in 
>>the netfilter.org patch-o-matic svn.
> 
> 
> Is this reasonably solid?  Does this operate on Layer 3, rather than Layer 2?

It operates like the IPv4 state matches. Solid? Well, I guess testers 
are welcome :)
