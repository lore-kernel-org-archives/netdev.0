From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Question on Netlink IPv6 routing table lookup
Date: Fri, 27 Sep 2013 02:16:13 +0200
Message-ID: <20130927001613.GA28287@order.stressinduktion.org>
References: <52409953.8040208@gont.com.ar> <20130924000453.GB2593@order.stressinduktion.org> <52440E48.3030102@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54060 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab3I0AQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 20:16:14 -0400
Content-Disposition: inline
In-Reply-To: <52440E48.3030102@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 07:36:56AM -0300, Fernando Gont wrote:
> Hi, Hannes,
> 
> On 09/23/2013 09:04 PM, Hannes Frederic Sowa wrote:
> > On Mon, Sep 23, 2013 at 04:41:07PM -0300, Fernando Gont wrote:
> >> If that's not (currently) possible, should I expect RTA_SRC to work as
> >> described above at some point in the future?
> > 
> > The RTA_SRC attriute matches on sutrees in the ipv6 routing table:
> > 
> > ip -6 r a default via fe80::1 dev eth0 from 2000::/64
> > ip -6 r a default via fe80::2 dev eth0 from 2000:1:/64
> > 
> > ip -6 r g :: from 2000::
> > ip -6 r g :: from 2000:1::
> > 
> > ...should return different routes. The from parameter is the RTA_SRC
> > attribute.
> 
> Isn't the "from" the "source network" in /proc/net/ipv6_route? (as
> described in <http://www.tldp.org/HOWTO/Linux+IPv6-HOWTO/proc-net.html>)

Correct.

> I have a node with multiple Ethernet interfaces, each of which connected
> to a different network where IPv6 Router Advertisements are received...
> and the "source network" is set to all-zeros in all cases.

As soon as you add a route with RTA_SRC you will see those two fields != 0.
Subtrees don't get used by router advertisments. Only way to set these fields
is by using the RTA_SRC from user-land.

Greetings,

  Hannes
