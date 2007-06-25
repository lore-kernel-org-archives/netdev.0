From: Patrick McHardy <kaber@trash.net>
Subject: Re: [CAN] [RFC] skb->iif usage and vcan driver background
Date: Mon, 25 Jun 2007 12:37:33 +0200
Message-ID: <467F9AED.1010309@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net> <467EA11A.7040109@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: j.hadi123@gmail.com, David Miller <davem@davemloft.net>,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64641 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbXFYKhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 06:37:37 -0400
In-Reply-To: <467EA11A.7040109@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Hello Patrick and Jamal,
> 
> as i felt a bit misunderstood in the discussion about the usage of
> skb->iif and the idea behind the virtual CAN driver i created four
> PDF-slides to clarify some issues. The slides may give you the
> appropriate background why the incoming (receiving) interface is
> relevant at user level (which is unusual e.g. for PF_INET). Additionally
> i collected some points what the VCAN driver does - and especially what
> it is not for. So you will see, that approaches like VLAN (regarding
> IEEE 802.1Q) is nothing that can be done with the CAN bus by design. The
> PDF can be found at the BerliOS OSS server:
> 
> http://download.berlios.de/socketcan/iif_and_vcan.pdf


I normally wouldn't have gone reading some PDF to explain a patch,
but this one was really worth it .. a couple of pictures of cars
with four applications using can0-can3 :)


> After reading the PDF ...
> 
> @Patrick: The (optional) loading of the vcan module and the
> specification of the needed number of vcan devices (for the wanted
> use-case) was a very easy thing up to now that did not require any
> additional configuration nor additional userspace tools (except saying
> 'ifconfig vcan0 up'). As only the use-case required number of interfaces
> are allocated at module load time, i do not see a need for an extra
> netlink interface to implement an IMHO obsolete vcan add/remove
> mechanism. What could the implementation of the netlink API bring for
> the vcan driver use-case?


You keep talkign about "the use-case". This is *your* usage case
any just because *you* need four interfaces doesn't mean everyone
else on the world does too.

Your last slide brings it to the point: "... configured at module
load time for the needed use-case:
- number of created vcan devices (current default=4)
- perform the loopback on driver level (current default=off)"

So you *do* have parameters for configuration and you're using the
wrong interface. Either drop them or use the correct interface.


