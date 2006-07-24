From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Help with bugfix for bond active-backup mode + vlans
Date: Mon, 24 Jul 2006 14:25:25 -0700
Message-ID: <200607242125.k6OLPPhg019864@death.nxdomain.ibm.com>
References: <200607241837.42626.Christophe.Devriese@eurid.eu> <200607241749.k6OHn1hg030011@death.nxdomain.ibm.com> <44C50A5E.80009@candelatech.com>
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59614 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751454AbWGXVZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 17:25:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6OLPSmM004154
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 17:25:28 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6OLPRGe254384
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 17:25:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6OLPRn7012162
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 17:25:27 -0400
To: Ben Greear <greearb@candelatech.com>
In-reply-to: <44C50A5E.80009@candelatech.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> wrote:

>Jay Vosburgh wrote:
>
>> 	Another possibility would be to have __vlan_hwaccel_rx check the
>> VLAN_DEV_INFO(skb->dev)->real_dev, and if that's a bonding device, apply
>> the same logic found in skb_bond().  Or, if there's some way to ask the
>> question "is dev a VLAN device?", then that same test could be put into
>> skb_bond() and all of the packet suppression fru fru could stay there.
>
>There is a flag in if.h to denote VLAN devices:

	Thanks, I missed that.

	Sadly, elegance remains elusive, since the by the time skb_bond
is called, the slave device the packet arrived on isn't available
(vlan->real_dev points to 'bond0' by this point), and that information
is needed to decide whether to drop the packet or not.

	The least grotty solution that comes to mind is to have
__vlan_hwaccel_rx call some skb_bond_suppress_dups() function directly,
and change skb_bond() to also call that function.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
