From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup
 behavior for VLAN interfaces
Date: Tue, 01 Aug 2006 09:10:06 -0700
Message-ID: <44CF7CDE.4080601@candelatech.com>
References: <44CA34D0.1070507@candelatech.com>	 <44CA87C5.1060905@candelatech.com>	 <20060730.205032.130618331.davem@davemloft.net>	 <200607311015.40255.Christophe.Devriese@eurid.eu>	 <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2>	 <20060801120836.GA29208@tuxdriver.com> <1154435614.5170.111.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:54489 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750782AbWHAQLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 12:11:06 -0400
To: hadi@cyberus.ca
In-Reply-To: <1154435614.5170.111.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> On Tue, 2006-01-08 at 08:08 -0400, John W. Linville wrote:
> [..]
> 
>>There is no doubt that we need to be able to do all three (vlan,
>>bridge, bond) at once.  I'm just not convinced we need to support
>>stacking them in every conceivable order.  
> 
> 
> In theory there should be no issues stacking netdevices in any order
> you want. In other words the hooks for doing so exist (albeit in some
> limited way[1]). Practically, some of the topologies of interconnected
> netdevices dont make a lot of sense. The danger is in restricting how
> the stacking happens and overlooking some future creative use.
> Safer to let the user own the policy and configure any way they want aka
> "shoot themselves in the foot".
> 
> 
>>And, I think that a
>>reconsideration of all three functions as a group could lead to
>>better/cleaner functionality with easier support for extension (e.g.
>>802.1s).
> 
> 
> Agreed. I have some very strong opinions on this subject that i could
> share with you if you want. For example, IMO, I think it would be a lot
> reasonable to assume that a VLAN or VLANS are attributes of a netdevice
> (just like IP addresses or MAC addresses are). 

As might be expected, I feel that VLANs are much more
useful as full-featured net devices.  I do not believe it is worth
decreasing functionality to try to 'clean up' the code.  There are people
doing interesting things with the mentioned virtual devices that the original
developers of the individual parts never envisioned, but I see that only
as a resounding success and validation of the architecture.

It is true that there are some interesting issues about where you add
the hooks to slurp up vlan, bridged, bonded and other type of virtual
device packets.

At least for some of my out-of-the-tree virtual lan devices (mac-vlan, in particular),
I thought it would be useful to allow dynamic registration of the layer-2 hooks such
as bridging.  This way, where there is no logical way to determine which virtual interface
should get first chance at a packet, the user can provide the ordering by adjusting
where the hooks sit in the chain.

Last time I mentioned this feature, it was pointed out that the net-filter hooks provide,
or come close to providing, this ability to stack.  If someone wants to work on
virtual device priority, it might be worth investigating this further and create an
API that makes this usable from kernel and user-space.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

