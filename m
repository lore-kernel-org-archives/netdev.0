From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: controlling ARP Proxy scope?
Date: Wed, 6 Jul 2005 04:20:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0507060405300.26027@filer.marasystems.com>
References: <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net> <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Jul 2005, Zdenek Radouch wrote:

>> proxy_arp simply ARPs if there is a route for the requested destination
>> going out on another interface than where the ARP was seen.
>
> In my case, the proxy replies to a request seen on the very same interface
> to which the route points to.

Are you really sure on this? This part has always worked fine for me with 
Linux proxy-arp and a large variety of different kernels.

> I find the idea to proxy based on routing tables quite questionable.

So do I. The manual proxy-arp entries method suits me much better, but is 
a pain due to lack of range support (probably why it got removed in 2.4)

> It may work is some pretty trivial cases, but will very obviously fail 
> with a more complex configuration.

Haven't managed to find a single situation not solveable yet.. and this 
involves pretty complex configurations..  I don't remember which of the 
sysctls mentioned earlier did the trick, but once enabled things starts to 
behave quite sanely even when there is multiple foreign networks 
unexpectedly carried on the same Ethernet. IIRC the settings I settled for 
was

   arp_ignore = 1
   arp_announce = 1

> I have seven or eight networks attached to the node, and I certainly do 
> not want to proxy for every single address one may find in the routing 
> tables.

Then don't.

> It is equally mind boggling to me how this could ever work with a stack 
> allowing source-based routing, that is, a stack allowing coexistence of 
> multiple, possibly conflicting routing tables.

Why not?

> Sounds to me like I am going to have to rewrite the module.  It needs to be
> configured manually

Well, for most setups it does work automagically. Just bring up the 
interfaces with the same IP, route the network out on the "main" interface 
having most hosts and host (or subnet) route the other out the other 
interface. ARP then follows automatically.

But in messy networks or when your routing table is not correct then 
sysctls is needed to restrict when to respond to stop you from responding 
to ARP requests to outside/foreign networks.

Probably isn't very hard to bring back the support for published proxy-arp 
entries if needed. But without range support it's a pain to maitain in 
most setups requiring proxy-arp as you then need an ARP entry for every 
"other" station on each interface involved in proxy-arp, meaning that if 
you proxy-arp a /24 network then you need 253 proxy-arp entries (one per 
station, defining which interface it belongs on). In the normal situation 
that you only act as a proxy-arp gateway for less than a handful stations 
this is a significant administrative overhead compared to just configuring 
routing which is required anyway.

Regards
Henrik
