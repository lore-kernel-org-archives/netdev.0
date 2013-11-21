From: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Subject: Re: [PATCH] bonding: If IP route look-up to send an ARP fails, mark
 in bonding structure as no ARP sent.
Date: Wed, 20 Nov 2013 22:01:40 -0800
Message-ID: <528DA1C4.8080106@oracle.com>
References: <528D5980.3040309@oracle.com> <12668.1384996699@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33996 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479Ab3KUGBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:01:46 -0500
In-Reply-To: <12668.1384996699@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thought will write to you again Jay.

On 11/20/2013 5:18 PM, Jay Vosburgh wrote:
> rama nichanamatlu <rama.nichanamatlu@oracle.com> wrote:
> 
>> During the creation of VLAN's atop bonding the underlying interfaces are
>> made part of VLAN's, and at the same bonding driver gets aware that VLAN's
>> exists above it and hence would consult IP routing for every ARP to  be
>> sent to determine the route which tells bonding driver the correct VLAN
>> tag to attach to the outgoing ARP packet. But, during the VLAN creation
>> when vlan driver puts the underlying interface into default vlan and then
>> actual vlan, in-between this if bonding driver consults the IP for a
>> route, IP fails to provide a correct route and upon which bonding driver
>> drops the ARP packet. ARP monitor when it
>> comes around next time, sees no ARP response and fails-over to the next
>> available slave. Consulting for a IP route, ip_route_output(),happens in
>> bond_arp_send_all().
>>
>> To prevent this false fail-over, when bonding driver fails to send an ARP
>> out it marks in its private structure, bonding{},  not to expect an ARP
>> response, when ARP monitor comes around next time ARP sending will be
>> tried again.
>>
>> Extensively tested in a VM environment; sr-iov intf->bonding intf->vlan
>> intf. All virtual interfaces created at boot time.
> 
> 	First, this patch appears to be for an older kernel, as the
> current mainline code is substantially different (e.g., master_ip is no
> longer used).
> 
> 	Second, won't this methodology mask legitimate failures, such as
> when a single arp_ip_target specifies a destination that is not ever
> reachable?  I.e., would specifying a permanently unreachable IP address
> as the arp_ip_target cause all slaves to always stay up (because no ARPs
> will ever be sent), even if no ARP replies are ever received?
> 
> 
An unreachable arp_target, a.b.c.d in a way that ip_route_output() fails
 as it cant even know which local interface to broadcast arp out.
Is that what you mean? Either with this change or not, bonding interface
is dead.Right? Without this change, it flip-flops (cycling) between
slaves and with this change stays on one slave.

>	-J
> 
