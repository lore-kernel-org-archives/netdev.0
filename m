From: Dan Williams <dcbw@redhat.com>
Subject: Re: Bridge stays down until a port is added
Date: Tue, 20 Sep 2011 15:20:26 -0500
Message-ID: <1316550027.1783.102.camel@dcbw.foobar.com>
References: <20110811070659.GA21307@torres.zugschlus.de>
	 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	 <20110917204257.GA2636@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498Ab1ITUUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 16:20:25 -0400
In-Reply-To: <20110917204257.GA2636@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-09-17 at 22:42 +0200, Marc Haber wrote:
> On Thu, Aug 11, 2011 at 08:17:06AM -0700, Stephen Hemminger wrote:
> > On Thu, 11 Aug 2011 09:06:59 +0200
> > Marc Haber <mh+netdev@zugschlus.de> wrote:
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
> The situation of a bridge is quite different from a physical ethernet
> interface. The physical interface is usually connected to a switch and
> is thus immediately up, even if no systems other than the switch are
> online.
> 
> In the case of a bridge on a virtualization host used to connect
> virtual machines, the bridge only goes up after the first VM was
> started.
> 
> In the IPv6 SLAAC case, the host tries start its radvd on the bridge
> well before the first VM comes up, the radvd barfs since the interface
> is not up, does not come up, and the VMs are without network. In this
> case, it is needed to force the bridge into an UP state earlier so
> that radvd can start.

So why not start radvd when the first interface is added to the bridge?
Or, really, make radvd aware of when the bridge comes up so it can
handle this itself, and make sure the VMs configuration can handle some
network dynamicism, since they'd need to anyway for fault tolerance...

Dan

> If people are supposed to add a dummy interface to the bridge if they
> want to use ipv6, this should be documented. And it's ugly.
> 
> Greetings
> Marc
> 
