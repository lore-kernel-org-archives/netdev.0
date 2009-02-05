From: Hendrik Sattler <post@hendrik-sattler.de>
Subject: Re: IXP4xx networking and phylib
Date: Thu, 05 Feb 2009 10:11:04 +0100
Message-ID: <498AAD28.9080903@hendrik-sattler.de>
References: <200901121705.07966.post@hendrik-sattler.de>	 <m3wsd0a0k3.fsf@maximus.localdomain> <2acbd3e40902041515p2624765bx5019c59c2b028780@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v1539.ncsrv.de ([89.110.150.23]:56663 "EHLO v1539.ncsrv.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229AbZBEJmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2009 04:42:25 -0500
In-Reply-To: <2acbd3e40902041515p2624765bx5019c59c2b028780@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming schrieb:
> On Mon, Jan 12, 2009 at 11:36 AM, Krzysztof Halasa <khc@pm.waw.pl> wrote:
>> Hi,
>>
>> Added CC: netdev.
>>
>> Hendrik Sattler <post@hendrik-sattler.de> writes:
>>
>>> My IXP465 MII port is connected to a Marvell switch (port 5). This port
>>> is "always on" and has no PHY registers. It is configured in hardware. The
>>> switch ports 1-4 have phy registers but that's not the matter.
>>> The problem is that there is no standard way in the platform info to tell the
>>> driver (now phylib) that there are _no_ PHY registers.
>>>
>>> Is there a standard way to say: enable the ethernet interface and be done with
>>> it?
>>> I currently do this by patching the driver. The PHYLIB patch makes that even
>>> easier but it would be better to not need patching at all (at least one
>>> driver less to patch).
> 
> There is a "fixed-phy" driver.  It allows you to configure things such
> that phylib will treat a PHY at a given address like it is a PHY with
> whatever attributes you choose.

Looks like a possible solution. I just cannot think about a possible
place when to call fixed_phy_add() to set the right registers for the
fixed port mode (100Mbit FD). It cannot be done before the driver init
code was run but that is after usual platform code stuff.
Additionally, ixp4xx_eth _and_ fixed set the mii_bus->id to 0, that
could be a problem! And ixp4xx_eth wants e.g. PHY 5 on its own MII bus
0, there is no way for fixed to actually deliver that. Fixed would have
to be a simple phy_driver without its own MII bus. Or ixp4xx_eth would
need to be more flexible on where the phy can live (so not only on its
own MII bus).

Or maybe I'm puzzled how that works together :-/

> The other option is to look at the
> DSA code from Lennert, and make the Marvell switch work with that (I
> haven't looked closely enough to see if that's feasible, but the end
> goal should be that all such integrated switches are covered by some
> framework).

DSA allows you to address each port separately by using a special packet
header. That's not wanted here, although I thought about it before (the
 88E6031/61 does support that but also VLAN header so special support is
not needed).

HS

