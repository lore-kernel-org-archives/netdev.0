From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Thu, 11 Aug 2011 15:41:50 -0700
Message-ID: <20110811154150.0e8d521d@nehalam.ftrdhcpuser.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110811205429.GB21307@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49977 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045Ab1HKWll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 18:41:41 -0400
In-Reply-To: <20110811205429.GB21307@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Aug 2011 22:54:29 +0200
Marc Haber <mh+netdev@zugschlus.de> wrote:

> Hi Stephen,
> 
> On Thu, Aug 11, 2011 at 08:17:06AM -0700, Stephen Hemminger wrote:
> > On Thu, 11 Aug 2011 09:06:59 +0200
> > Marc Haber <mh+netdev@zugschlus.de> wrote:
> > > Is that a feature? If so, why does the interface stay pingable after
> > > removing the dummy0 interface from the bridge?
> > 
> > Yes, there are no links to send a packet so it seems logical
> > that there would be no carrier.
> 
> Yes, but if I can configure an IP address to the bridge I would expect
> it to be reachable even if there are no interfaces in the bridge.
> "Older" kernels used to behave like that.
> 
> > > New new behavior is somewhat unhandy when one uses the bridge address
> > > for services that the host offers, to save on IP addresses and
> > > networks (for example, when one has only a single IP address and a
> > > single additional network), since one has to take extra measures to
> > > have the addresses on the bridge interface reachable.
> > > 
> > > Or am I doing things wrong?
> > 
> > The goal is to make the bridge behave the same as a vlan or
> > a physical device.  Could you explain better what the application(s)
> > would expect.
> 
> I have a number of housing systems that have only a single IP address
> on their eth0, but an IP network routed to bring virtual machines
> running on these systems online. The virtual machines are all on br0,
> and the host is routing between eth0 and br0. To route, it needs its
> own IP address on br0, and I have not resisted the temptation of
> running servies on the br0 IP address.
> 
> It is unnatural to not have the br0 IP address reachable unless the
> first VM is running. I have, in the mean time, created a dummy0
> interface and am adding dummy0 to br0 just to have the bridge
> operational, but that's a hack. I'd like to have the old behavior back
> as an optional configuration.

I still say why should bridge behave differently than bonding
or a physical device? I wonder if part of the difference is that real
devices have transmit queues and the test for link being up
is done in IP based on transmit queue rather than on carrier state.

On routers, it is common to assign some addresses to loopback device so
they stay up independent of the underlying links.
