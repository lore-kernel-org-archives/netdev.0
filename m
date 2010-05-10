From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:33:00 +0200
Message-ID: <4BE8191C.8020302@trash.net>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se> <1273222403.2261.26.camel@edumazet-laptop> <OF803EE436.793B95D8-ONC125771C.003295C9-C125771C.00341AFF@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47248 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab0EJOdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:33:00 -0400
In-Reply-To: <OF803EE436.793B95D8-ONC125771C.003295C9-C125771C.00341AFF@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/05/07 10:53:23:
>>> 3) I would expect lost pkgs to be accounted on eth0 instead of
>>>    the VLAN interface(s) since that is where the pkg is lost, why
>>>    isn't it so?
>> You try to send packets on eth0.XXX, some are dropped, and accounted for
>> on eth0.XXX stats. What is wrong with this ?
> 
> In this case one lost pkg is accounted for twice, once on eth0.1 and
> once more on eth0.1.1. Note that eth0.1.1 is stacked on
> top of eth0.1
> 
> I would at least expect eth0 to also account lost pkgs too.
> I was confused by the current accounting as I knew that
> the underlying HW I/F should be the only I/F that could
> drop pkgs.

In case of NET_XMIT_CN, the packet is dropped by the qdisc before
it reaches eth0, so its only accounted on the upper devices.

>> If you want to avoid this, just add queues to your vlans
>>
>> ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103
> 
>>From memory now, but that didn't help. Still accounts pgks
> as described. Why would where to account pkgs be affected by
> queue or no queue?

If a queue is used on the vlan device, it will queue the packet
until the lower device is able to transmit it (unless its own
queue overflows).
