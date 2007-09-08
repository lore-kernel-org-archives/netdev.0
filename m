From: Bill Fink <billfink@mindspring.com>
Subject: Re: error(s) in 2.6.23-rc5 bonding.txt ?
Date: Sat, 8 Sep 2007 02:05:11 -0400
Message-ID: <20070908020511.1285c043.billfink@mindspring.com>
References: <46E1CA81.6050808@hp.com>
	<32121.1189207861@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:51961 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750929AbXIHGFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 02:05:24 -0400
In-Reply-To: <32121.1189207861@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 07 Sep 2007, Jay Vosburgh wrote:

> Rick Jones <rick.jones2@hp.com> wrote:
> [...]
> >>         Note that this out of order delivery occurs when both the
> >>         sending and receiving systems are utilizing a multiple
> >>         interface bond.  Consider a configuration in which a
> >>         balance-rr bond feeds into a single higher capacity network
> >>         channel (e.g., multiple 100Mb/sec ethernets feeding a single
> >>         gigabit ethernet via an etherchannel capable switch).  In this
> >>         configuration, traffic sent from the multiple 100Mb devices to
> >>         a destination connected to the gigabit device will not see
> >>         packets out of order.  

I would just change the last part of the last sentence to:

	configuration, traffic sent from the multiple 100Mb devices to
	a destination connected to the gigabit device will not usually
	see packets out of order in the absence of congestion on the
	outgoing gigabit ethernet interface.

If there was momentary congestion on the outgoing gigabit ethernet
interface, I suppose it would be possible to get out of order delivery
if some of the incoming packets on the striped round-robin interfaces
had to be buffered a short while before delivery was possible.

> 	The text probably is lacking in some detail, though.  The real
> key is that the last sender before getting to the destination system has
> to do the round-robin striping.  Most switches that I'm familiar with
> (again, never seen one, but willing to believe there is one) don't have
> round-robin as a load balance option for etherchannel, and thus won't
> evenly stripe traffic, but instead do some math on the packets so that a
> given "connection" isn't split across ports.

Just FYI, the "i" series of Extreme switches (and some of their other
switches) support round-robin load balancing.  We consider this an
extremely useful feature (but only use it for switch-to-switch link
aggregation), and bemoan its lack in their newer switch offerings.
Force10 switches also have a pseudo round-robin load balancing capability
which they call packet-based, which works by distributing packets based
on the IP Identification field (and only works for IPv4).  One downside
of the Force10 feature is that it is a global setting and thus affects
all link aggregated links (the Extreme feature can be set on a per
link aggregated link basis).

						-Bill
