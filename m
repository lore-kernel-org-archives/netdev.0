From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: L2 switching in igb
Date: Mon, 14 Sep 2009 13:02:52 +0300
Message-ID: <4AAE14CC.2000609@voltaire.com>
References: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com>	<5f2db9d90909032135l26cfdba6n52329f6be75c16a5@mail.gmail.com>	<4AA8B317.2080706@voltaire.com> <4AA937A1.9070504@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:42405 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750746AbZINKC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 06:02:57 -0400
In-Reply-To: <4AA937A1.9070504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote:
> You are correct, the vSwitch can basically do VEPA by disabling local 
> loopback enable bit in the DTXSWC register.  This would force all 
> traffic from the PF/VFs out the lan physical port and from the lan 
> physical port to the appropriate PF/VFs without doing any switching in 
> between PF/VFs.
To have VEPA support another bit has to be programmed... its the one 
that doesn't let the PF to forward a packet to a VF whose source mac 
matches the one in the packet (e.g multicast sender).

> add an rtnl_link_ops interface to handle vSwitch configuration that 
> could then be applied to the igb netdevs that support VEPA/vSwitch 
> technologies.  A subset of that interface could then be dedicated to 
> VF configuration to handle things such as spawning VFs, setting the 
> default mac addresses, security controls, etc.
Yes, lets do that. I'd like to suggest that a "VF programmable from user 
space" context  will contain a <mac, vlan-id, priority-bits, rate> 
tuple, such that in the absence of vlan tag, the VF driver will "sign" 
the packet (skb) with vlan-id and priority-bits assigned by the admin 
and the PF NIC will mandate that the VF originated traffic will not 
exceed the rate.

Or.


Or.

