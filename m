From: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Subject: RE: [Bridge] [PATCH] macvlan: add tap device backend
Date: Fri, 7 Aug 2009 12:10:07 -0700
Message-ID: <004f01ca1792$b24a7a90$16df6fb0$@edu>
References: <0199E0D51A61344794750DC57738F58E6D6A6CD7F6@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Paul Congdon \(UC Davis\)'" <ptcongdon@ucdavis.edu>,
	"'Fischer, Anna'" <anna.fischer@hp.com>,
	"'Arnd Bergmann'" <arnd@arndb.de>, <herbert@gondor.apana.org.au>,
	<mst@redhat.com>, <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <ogerlitz@voltaire.com>,
	<evb@yahoogroups.com>, <davem@davemloft.net>
To: <drobbins@funtoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:13160 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908AbZHGTKR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 15:10:17 -0400
In-Reply-To: 
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Responding to Daniel's questions...

> I have some general questions about the intended use and benefits of 
> VEPA, from an IT perspective:
> 
> In which virtual machine setups and technologies do you forsee this 
> interface being used?

The benefit of VEPA is the coordination and unification with the external network switch.  So, in environments where you are needing/wanting your feature rich, wire speed, external network device (firewall/switch/IPS/content-filter) to provide consistent policy enforcement, and you want your VMs traffic to be subject to that enforcement, you will want their traffic directed externally.  Perhaps you have some VMs that are on a DMZ or clustering an application or implementing a multi-tier application where you would normally place a firewall in-between the tiers.

> Is this new interface to be used within a virtual machine or 
> container, on the master node, or both?

It is really an interface to a new type of virtual switch.  When you create virtual network, I would imagine it being a new mode of operation (bridge, NAT, VEPA, etc).

> What interface(s) would need to be configured for a single virtual 
> machine to use VEPA to access the network?

It would be the same as if that machine were configure to use a bridge to access the network, but the bridge mode would be different.

> What are the current flexibility, security or performance limitations 
> of tun/tap and bridge that make this new interface necessary or 
> beneficial?

If you have VMs that will be communicating with one another on the same physical machine, and you want their traffic to be exposed to an in-line network device such as a application firewall/IPS/content-filter (without this feature) you will have to have this device co-located within the same physical server.  This will use up CPU cycles that you presumable purchased to run applications, it will require a lot of consistent configuration on all physical machines, it could invoke potentially a lot of software licensing, additional cost, etc..  Everything would need to be replicated on each physical machine.  With the VEPA capability, you can leverage all this functionality in an external network device and have it managed and configured in one place.  The external implementation is likely a 
 higher performance, silicon based implementation.  It should make it easier to migrate machines from one physical server to another and maintain the same network policy enforcement.

> Is this new interface useful at all for VPN solutions or is it
> *specifically* targeted for connecting virtual machines to the 
> network?

I'm not sure I see the benefit for VPN solutions, but I'd have to understand the deployment scenario better.  Certainly this is targeting connecting VMs to the adjacent physical LAN.

> Is this essentially a bridge with layer-2 isolation for the virtual 
> machine interfaces built-in? If isolation is provided, what mechanism 
> is used to accomplish this, and how secure is it?

That might be an over simplification, but you can achieve layer-2 isolation if you connect to a standard external switch.  If that switch has 'hairpin' forwarding, then the VMs can talk at L2, but their traffic is forced through the bridge.  If that bridge is a security device (e.g. firewall), then their traffic is exposed to that.

The isolation in the outbound direction is created by the way frames are forwarded.  They are simply dropped on the wire, so no VMs can talk directly to one another without their traffic first going external.  In the inbound direction, the isolation is created using the forwarding table.  

> Does VEPA look like a regular ethernet interface (eth0) on the virtual 
> machine side?

Yes

> Are there any associated user-space tools required for configuring a 
> VEPA?
>

The standard brctl utility has been augmented to enable/disable the capability.
 
> Do you have any HOWTO-style documentation that would demonstrate how 
> this interface would be used in production? Or a FAQ?
>

None yet.
 
> This seems like a very interesting effort but I don't quite have a 
> good grasp of VEPA's benefits and limitations -- I imagine that others 
> are in the same boat too.
> 

There are some seminar slides available on the IEEE 802.1 web-site and elsewhere.  The patch had a reference to a seminar, but here is another one you might find helpful:

http://www.internet2.edu/presentations/jt2009jul/20090719-congdon.pdf

I'm happy to try to explain further...

Paul


