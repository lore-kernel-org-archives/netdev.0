From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: sysfs question
Date: Thu, 12 Nov 2009 18:44:36 +0100
Message-ID: <4AFC4984.8000803@hartkopp.net>
References: <200911021533.25345.matthias.fuchs@esd.eu>	<20091106100427.GB323@e-circ.dyndns.org>	<20091109112331.GE323@e-circ.dyndns.org>	<4AF83EB7.3070401@grandegger.com>	<20091112100053.GA322@e-circ.dyndns.org>	<4AFBE0DD.1000408@grandegger.com>	<20091112103940.GC322@e-circ.dyndns.org> <20091112090041.1536ccc8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:39589 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739AbZKLRoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 12:44:34 -0500
In-Reply-To: <20091112090041.1536ccc8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 12 Nov 2009 11:39:41 +0100
> Kurt Van Dijck <kurt.van.dijck@eia.be> wrote:
> 
>> Hi,
>>
>> Within the socketcan project, we came into a situation that
>> might benefit with input from the netdev mailing list.
>>
>> The main issue is the policy to add sysfs properties in
>> /sys/class/net/canX.
>>
>> The reason for this is that cards (devices) with multiple network
>> interfaces may require properties per network.
>>
>> An obvious property would be the 'channel number of the card'. Other
>> properties could be things like type of output circuitry, ..., rather
>> hardware specific.
>>
>> I see currently 3 options:
>> 1) such properties in /sys/class/net/canX would be allowed.
>> 2) such properties would belong in /sys/class/net/canX/<subdirectory tbd>/
>> 3) such properties would go somewhere else.
>>
>> Some input with regard to sysfs policies would be helpfull.
>>
>> Kurt
> 
> It sounds like the property you are proposing is a property of the
> upper network layer not the hardware. Putting more properties in sysfs
> is good if is hardware related, but awkward if it is really a protocol
> attribute.

Then it would be good here :-)

The problem that can occur here is:

You plug-in a PCMCIA CAN card that has two CAN controllers on-board.

That means, you're getting two CAN independed network interfaces can0 and can1
pointing to ONE pcmcia device. Both of the CAN netdevs may have different
bitrates or other CAN controller specific settings (like the type of output
circuitry Kurt mentioned).

Finally the PCMCIA card itself may contain a serial number and/or a license
information that needs to be made available.

It's definitely no upper network layer stuff.

Regards,
Oliver
