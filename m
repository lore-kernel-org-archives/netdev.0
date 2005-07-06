From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: controlling ARP Proxy scope?
Date: Wed, 6 Jul 2005 17:32:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0507061718500.6628__18890.3774520897$1120664341$gmane$org@filer.marasystems.com>
References: <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net> <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net> <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1npg80@smtp05.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <3u3gb7$1npg80@smtp05.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Jul 2005, Zdenek Radouch wrote:

> Well, how do I tell it that I want to proxy for all machines on the
> 192.168.13.128/29 net attached to eth0.5, but not for any of
> the machines on 192.168.2.0/24 attached to eth0.6 ?

For whom going where?

What is eth0.5? A tagged 802.1q vlan on eth0, or something else? (i.e. is 
it a interface of it's own according to ip link show, or just an alias?)

> It just occured to me that if I misunderstood the semantics, the setup
> may be wrong.  I assumed that turning the proxy arp on on interface X
> would make the interface X answer (proxy) the ARP queries.
> Is that correct?

Yes.

>>> It is equally mind boggling to me how this could ever work with a stack
>>> allowing source-based routing, that is, a stack allowing coexistence of
>>> multiple, possibly conflicting routing tables.
>>
>> Why not?
>
> Because in rule-based routing, a table entries are only valid when the
> corresponding
> rule hits, based on the source address.  In the absence of a source address
> as is the case of an ARP request, how could you possibly determine which
> of the routing tables should be consulted to decide whether the ARP query
> should be answered?

ARP requests do have valid source addresses, at least the normal ARP 
queries. The duplicate IP check ARP requests and a few other obscure cases 
don't.

> I agree that you wouldn't want to enter discrete addresses.
> But it could be a simple command using the standard subnet notation:
>
> arp_proxy --add 10.1.2.0/24 [11:22:33:44:55:66]
> (optional Eth address for 3rd party proxy ARP).

Which to my experience is all automatic from the routing table. But I do 
remember some slight complications in source routed networks but nothing 
major. Before arp_ignore existed I often used source routing as a 
substitute for keeping proxy-ARP at bay but I don't remember the exact 
details.

I only experienced problems when there was other IP networks on the same 
Ethernet but not known to the box. In this case I had to enable the 
arp_ignore sysctl to stop answering "other" ARP queries for networks not 
defined on the same Ethernet interface. I also used the arp_announce to 
keep the source address of ARP responses under control.

In addition in a setup which involved stations with IP addresses identical 
to that of one of my own other Ethernet interfaces I had to hack the 
kernel slightly to make it possible to ignore ARP duplicate IP check 
packets on the relevant interfaces. But this is very special setup 
involving NAT and other nastinesses which shouldn't be encountered in any 
reasonably normal network situation.

Regards
Henrik
