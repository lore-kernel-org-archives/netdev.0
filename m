From: "Ronnie Sahlberg" <ronnie_sahlberg@ozemail.com.au>
Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of entries.
Date: Fri, 9 Apr 2004 23:16:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <014801c41e34$d3759e50$6501010a@C5043436>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For fast routing lookups for IPv4, has anyone considered :

Treat all addresses as class c networks, dont route on anything else than
class c networks.
Limit the number of next-hop routers to 256.  With next-hop-router index 0
meaning  no route to that network.

Use a 16Mbyte large lookup table of bytes, where each byte represents the
next hop router.

Let the route to A.B.C.x re represented by the next-hop router described in
   table[A*65536+B*256+C]

Then a route lookup would be O(1), a simple table lookup.

Route insertions/deletions would take longer but anyway, the lookup would be
fast,  essentially a shift by 8 bits
and one memory read from the table.  At the cost of 16Mbyte wasted of kernel
memory.


Wasteful, yes, only really useful if you have enormous routing tables, can
not do policy routing   but fast.
