From: Patrick McHardy <kaber@trash.net>
Subject: Re: Funny Routing change since 2.6.16.x
Date: Wed, 07 Feb 2007 18:07:03 +0100
Message-ID: <45CA0737.40308@trash.net>
References: <200702071756.34409.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53588 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161382AbXBGRHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 12:07:08 -0500
In-Reply-To: <200702071756.34409.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Dear network gurus,
> 
> I used to change the source address on an PPPoE connection by using
> these commands:
> 
> /sbin/ifconfig ppp0:1 $SRCADDR
> /sbin/ip route add default dev ppp0 src $SRCADDR
> 
> where SRCADDR is an address in a different network
> than the local and peer address for ppp0.
> 
> That works fine until Linux 2.6.13.1.
> 
> When I use Kernel 2.6.16.32, 2.6.19.2 or 2.6.19.3
> this stops working.
> 
> Funnily it WORKS, when the machine just has to answer.
> It DOESN'T work, when the machine initiates an connection.
> 
> I verified that on the receiving side of a ping with tcpdump.
> 
> I also verified that "ip route get $OTHER_HOST" would use the route 
> with src address  set to "SRCADDR" from above.
> 
> I tried using a default route like "ip route add default via $GATEWAY src $SRCADDR",
> but that doesn't work either.
> 
> I attached the config for the old working kernel and the 2.6.19.3 config
> for reference.
> 
> We noticed no problems with ethernet alias interfaces.
> 
> The (production) machine is a PC doing SNAT, DNAT, MASQUERADE 
> and iptables based stateful inspection firewalling. Policy routing is 
> compiled in, but not used at all.
> 
> If you need the iptables rules anyway, just tell me.

My guess is that you're using MASQUERADE on ppp0, which since 2.6.14
doesn't exclude locally generated packets anymore, so it translates
them to the primary ppp0 address. For replies it works because NAT
is already set up for the incoming packet, without masquerading.
