From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Bridge stays down until a port is added
Date: Sat, 17 Sep 2011 22:42:57 +0200
Message-ID: <20110917204257.GA2636@torres.zugschlus.de>
References: <20110811070659.GA21307@torres.zugschlus.de>
 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:50498 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab1IQUm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 16:42:58 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R51iz-0000jb-60
	for netdev@vger.kernel.org; Sat, 17 Sep 2011 22:42:57 +0200
Content-Disposition: inline
In-Reply-To: <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2011 at 08:17:06AM -0700, Stephen Hemminger wrote:
> On Thu, 11 Aug 2011 09:06:59 +0200
> Marc Haber <mh+netdev@zugschlus.de> wrote:
> > New new behavior is somewhat unhandy when one uses the bridge address
> > for services that the host offers, to save on IP addresses and
> > networks (for example, when one has only a single IP address and a
> > single additional network), since one has to take extra measures to
> > have the addresses on the bridge interface reachable.
> > 
> > Or am I doing things wrong?
> 
> The goal is to make the bridge behave the same as a vlan or
> a physical device.  Could you explain better what the application(s)
> would expect.

The situation of a bridge is quite different from a physical ethernet
interface. The physical interface is usually connected to a switch and
is thus immediately up, even if no systems other than the switch are
online.

In the case of a bridge on a virtualization host used to connect
virtual machines, the bridge only goes up after the first VM was
started.

In the IPv6 SLAAC case, the host tries start its radvd on the bridge
well before the first VM comes up, the radvd barfs since the interface
is not up, does not come up, and the VMs are without network. In this
case, it is needed to force the bridge into an UP state earlier so
that radvd can start.

If people are supposed to add a dummy interface to the bridge if they
want to use ipv6, this should be documented. And it's ugly.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
