From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Bridge stays down until a port is added
Date: Thu, 11 Aug 2011 22:54:29 +0200
Message-ID: <20110811205429.GB21307@torres.zugschlus.de>
References: <20110811070659.GA21307@torres.zugschlus.de>
 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:57678 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813Ab1HKUya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 16:54:30 -0400
Content-Disposition: inline
In-Reply-To: <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Thu, Aug 11, 2011 at 08:17:06AM -0700, Stephen Hemminger wrote:
> On Thu, 11 Aug 2011 09:06:59 +0200
> Marc Haber <mh+netdev@zugschlus.de> wrote:
> > Is that a feature? If so, why does the interface stay pingable after
> > removing the dummy0 interface from the bridge?
> 
> Yes, there are no links to send a packet so it seems logical
> that there would be no carrier.

Yes, but if I can configure an IP address to the bridge I would expect
it to be reachable even if there are no interfaces in the bridge.
"Older" kernels used to behave like that.

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

I have a number of housing systems that have only a single IP address
on their eth0, but an IP network routed to bring virtual machines
running on these systems online. The virtual machines are all on br0,
and the host is routing between eth0 and br0. To route, it needs its
own IP address on br0, and I have not resisted the temptation of
running servies on the br0 IP address.

It is unnatural to not have the br0 IP address reachable unless the
first VM is running. I have, in the mean time, created a dummy0
interface and am adding dummy0 to br0 just to have the bridge
operational, but that's a hack. I'd like to have the old behavior back
as an optional configuration.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
