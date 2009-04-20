From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Mon, 20 Apr 2009 11:37:31 -0700
Message-ID: <30257.1240252651@death.nxdomain.ibm.com>
References: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com> <49ECBBF0.80202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefan novak <lms.brubaker@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:48727 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbZDTSh1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 14:37:27 -0400
In-reply-to: <49ECBBF0.80202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:

>stefan novak a =C3=A9crit :
>> Hello list,
>>=20
>> I've got a Problem with my bladecenter and bond interfaces.
>> My Server has 2 interface, each on a seperate switch. Each
>> serverinterface is connected via a trunk to one of the switches.
>> Each switch has a trunk to stacked-backbone switch.
>>=20
>> nic1 --trunk--> bladesw1 --trunk--> backbone switch
>> nic2 --trunk--> bladesw2 --trunk--> backbone switch
>>=20
>> So far vlan and trunking works as expected. But if one trunk
>> connection from a bladeswitch to the backbone switch is down the
>> mii-tool cant recognize this.
>
>What is the exact problem on this one ?

	This is the expected behavior, the external switch to
bladecenter switch (ESM) link status does not affect the ESM to blade
link status.

	Unless... your ESM supports "trunk failover."  I believe the
Cisco ESMs do, I'm not sure about others.  With trunk failover enabled,
loss of link on an external switch port will in turn drop link on the
corresponding internal switch ports.  There is a long-ish delay for
this, on the order of 750 ms, as I recall.

>> I tried to use an arp target on the backbone switch to check the
>> connection state.
>>=20
>> Now i'm running into problems. :(
>> My bladesw1 is configured with a trunk and a private vlan id of 600.
>> On the backbone switch is a server in the vlan 600 connected, but i
>> can't get an arp request.
>>=20
>> What can be the problem, or is it possible to add a vlan tag on the =
arp check?
>>=20
>
>What driver is in use on your NIC interface ?
>
>Could you post your bonding settings ?
>
>cat /proc/net/bonding/bond0

	Sufficiently recent versions of bonding should VLAN tag the ARP
probes, provided you are using a VLAN device configured above the bond.
My recollection is that VLAN tagging of ARP probes was added about thre=
e
years ago.

	If the switch port is configured as native to a VLAN, then it
should tag everything coming in.

	As Eric asks, what are you running?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
