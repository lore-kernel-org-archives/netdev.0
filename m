From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Tue, 16 Mar 2004 00:21:45 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403160017050.8576-100000@netcore.fi>
References: <20040315135753.28b945fa.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: timg@tpi.com, <anton@samba.org>, <netdev@oss.sgi.com>,
        <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040315135753.28b945fa.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Responding to both Dave and Andi in the same message..

On Mon, 15 Mar 2004, David S. Miller wrote:
> > Isn't there a problem when an outside attacker brute-force pings every 
> > IP address in some order?  The intent here is to overload the router 
> > to do a lot of ARP/ND requests which result to nothing.
> 
> Since another request for the same IP won't spam out another ARP
> request whilst we have an existing entry in state "resolve in progress",
> the damage is quite limited I'd say.

Right -- Unless you consider the amount of "resolve in progress" 
-state and the resulting ARP requests to be harmful.

E.g., if I had 100 hosts each sending 1000 packets per second to bogus 
v6 addresses, that would mean 100,000 ARP requests / second, and 
before the resolving times out, the total number could be quite high, 
right? 

> Sounds to me like the backlog of packets we keep around for each
> "resolve in progress" neighbour cache entry is more interesting
> for DoS purposes :-)

That, too :)

[ Andi Kleen: ]
> > Isn't there a problem when an outside attacker brute-force pings every
> > IP address in some order?  The intent here is to overload the router
> > to do a lot of ARP/ND requests which result to nothing.
>
> Note that the max number of active neighbours per interface is limited. There
> is a natural limit on how many entries the hash tables can have.
> The user can increase this with sysctls, but the defaults should be
> safe.

Right, these are safe against resource exhaustion attacks.  
Unfortunately, they aren't safe from being used as a means to deny 
someones (valid) access to the link.  For example, by keeping on 
pinging, could you keep the number of neighbors per interface 
constantly maxed out, not allowing new (valid) neighbors?

(I this depends on the definition of "active neighbor".)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
