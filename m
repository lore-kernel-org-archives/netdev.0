From: "David S. Miller" <davem@davemloft.net>
Subject: ipmr_get_route()
Date: Mon, 30 Aug 2004 17:14:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830171436.145e3869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is very broken.

It gets called only by rt_fill_info() to get multicast routing
information from ipmr.c, the skb it passes in is the rtnetlink
message.

But look at what ipmr_get_route() actually does.  If the cache
entry cannot be found, it tries to build an IPV4 packet using
this packet to resolve the missing cache entry!

I think we don't crash here only because most of the time the
user has not specified an explicit input interface in the route
lookup request, and therefore skb->dev is NULL when ipmr_get_route()
takes a look at it.

Nevertheless things are seriously busted here.  Any takers to
fix this thing up? :-)
