From: Ben Greear <greearb@candelatech.com>
Subject: Re: Help with bugfix for bond active-backup mode + vlans
Date: Mon, 24 Jul 2006 14:35:30 -0700
Message-ID: <44C53D22.6040908@candelatech.com>
References: <200607241837.42626.Christophe.Devriese@eurid.eu> <200607241749.k6OHn1hg030011@death.nxdomain.ibm.com> <44C50A5E.80009@candelatech.com> <200607242125.k6OLPPhg019864@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:56987 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932255AbWGXVfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 17:35:39 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200607242125.k6OLPPhg019864@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Jay Vosburgh wrote:
>>
>>
>>>	Another possibility would be to have __vlan_hwaccel_rx check the
>>>VLAN_DEV_INFO(skb->dev)->real_dev, and if that's a bonding device, apply
>>>the same logic found in skb_bond().  Or, if there's some way to ask the
>>>question "is dev a VLAN device?", then that same test could be put into
>>>skb_bond() and all of the packet suppression fru fru could stay there.
>>
>>There is a flag in if.h to denote VLAN devices:
> 
> 
> 	Thanks, I missed that.
> 
> 	Sadly, elegance remains elusive, since the by the time skb_bond
> is called, the slave device the packet arrived on isn't available
> (vlan->real_dev points to 'bond0' by this point), and that information
> is needed to decide whether to drop the packet or not.
> 
> 	The least grotty solution that comes to mind is to have
> __vlan_hwaccel_rx call some skb_bond_suppress_dups() function directly,
> and change skb_bond() to also call that function.

Can you use skb->input_dev?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

