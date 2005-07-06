From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: controlling ARP Proxy scope?
Date: Tue, 05 Jul 2005 21:55:29 -0400
Message-ID: <3u3gb7$1no73u__30675.3272460357$1120615680$gmane$org@smtp05.mrf.mail.rcn.net>
References: <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net> <Pine.LNX.4.61.0507022316310.26953@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0507022316310.26953@filer.marasystems.com>
References: <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 11:21 PM 7/2/05 +0200, Henrik Nordstrom wrote:
>On Fri, 1 Jul 2005, Zdenek Radouch wrote:
>
>> So, left with only a binary flag in /proc,  and network definition on the
>> interface,
>> I assumed (perhaps naively) that the arp would proxy only for the addresses
>> within the subnet defined for the interface (on which the proxy arp is
>> turned on).
>> However, that does not seem to be the case.
>
>You may be able to tune this with either arp_filter or arp_ignore.

Unfortunately I can't.  Not without adding more code to what is quite
obviously a bunch of kludgy patches for an ill-conceived ARP proxy design.

>
>> I have an interface with address 10.1.2.219 and mask 255.255.255.248 with
>> proxy arp turned on on this interface, and the machine is responding
>> (I see that with tcpdump) to arp requests for address 10.1.2.1, i.e.,
>> an address outside of the proxy interface's subnet.
>
>Correct.
>
>> Can anyone explain the behavior?
>
>proxy_arp simply ARPs if there is a route for the requested destination 
>going out on another interface than where the ARP was seen.

In my case, the proxy replies to a request seen on the very same interface
to which the route points to.  That's wrong no matter how you look at it;
this is a route to which this node will be routing, i.e., this node will be
ARPing
for this route address - it itself should not reply to such requests, nor
could
it ever successfully do so.

I find the idea to proxy based on routing tables quite questionable.  It
may work
is some pretty trivial cases, but will very obviously fail with a more complex
configuration. I have seven or eight networks attached to the node, and I
certainly do not want to proxy for every single address one may find in the
routing tables.

It is equally mind boggling to me how this could ever  work with a stack
allowing
source-based routing, that is, a stack allowing coexistence of multiple,
possibly
conflicting routing tables.  

Sounds to me like I am going to have to rewrite the module.  It needs to be
configured manually - the notion that it could work automagically, without
external configuration is quite unrealistic, as one can see from the code
in arp_filter and arp_ignore.

Thanks for the pointers.
-Zdenek
