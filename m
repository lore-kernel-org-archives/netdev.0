From: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Subject: Re: [PATCH] bonding: If IP route look-up to send an ARP fails, mark
 in bonding structure as no ARP sent.
Date: Thu, 21 Nov 2013 12:34:08 -0800
Message-ID: <528E6E40.6020201@oracle.com>
References: <528D5980.3040309@oracle.com> <20131121111022.GA30998@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40649 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab3KUUeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 15:34:16 -0500
In-Reply-To: <20131121111022.GA30998@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 3:10 AM, Veaceslav Falico wrote:
> On Wed, Nov 20, 2013 at 04:53:20PM -0800, rama nichanamatlu wrote:
>> During the creation of VLAN's atop bonding the underlying interfaces
>> are made part of VLAN's, and at the same bonding driver gets aware
>> that VLAN's exists above it and hence would consult IP routing for
>> every ARP to  be sent to determine the route which tells bonding
>> driver the correct VLAN tag to attach to the outgoing ARP packet. But,
>> during the VLAN creation when vlan driver puts the underlying
>> interface into default vlan and then actual vlan, in-between this if
>> bonding driver consults the IP for a route, IP fails to provide a
>> correct route and upon which bonding driver drops the ARP packet. ARP
>> monitor when it
>> comes around next time, sees no ARP response and fails-over to the
>> next available slave. Consulting for a IP route,
>> ip_route_output(),happens in bond_arp_send_all().
> 
> bonding works as expected - nothing to fix here. And even as a
> workaround/hack - I'm not sure we need that to suppress one failover *only*
> when vlan is added on top.
> 
>>
Thank U.
With *out* this change our systems failed system testing, to
consistently be on designated primary interface on *every* single
reboot. With this change the behavior was as expected even after a few
thousand reboots & System testing could move to next level catching an
another bug in sr-iov :). And Without, the outcome was less predictable
after a reboot and bonding was on a different slave each time.
-Rama
>> To prevent this false fail-over, when bonding driver fails to send an
>> ARP out it marks in its private structure, bonding{},  not to expect
>> an ARP response, when ARP monitor comes around next time ARP sending
>> will be tried again.
>>
>> Extensively tested in a VM environment; sr-iov intf->bonding
>> intf->vlan intf. All virtual interfaces created at boot time.
>>
