From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Thu, 17 Jul 2003 09:50:49 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307170940280.1348-100000@netcore.fi>
References: <200307170003.EAA12843@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307170003.EAA12843@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > > > What happens when you do "ping6 3FFE:FFFF:A:B::1" ?
> 
> ping did, does and will work and I do not understand what you want
> to say or ask. Do you want to know how it works?
> 
> Well, IPv6 stack looks up the address in routing tables, finds the route,
> sees that it is on-link, sends NDISC, receiver replies, we create a frame
> and send the echo request. To continue? :-)

(Sorry, it seems I've caused a lot of confusion in some parts of this 
thread by typoeing link-local address when I used link-layer address.. 
sorry)

So, assume you have 3FFE:FFFF:A:B::/64 prefix on link.  On a host on that 
link, you've manually configured the next-hop to be the router on that 
link, 3FFE:FFFF:A:B::1.

The procedure to obtain the knowledge on where to send packets whose 
next-hop is 3FFE:FFFF:A:B::1 seems quite simple, similar to ping6.

As to obtaining the link-*local* address, there are several procedures 
none of which I would recomment.  Checking the source address of a ND 
packet (e.g. in the ping6 example above), or using a protocol like ICMP 
name information queries (draft-ietf-ipngwg-icmp-name-lookups-10.txt).

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
