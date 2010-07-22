From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] bonding: change test for presence of
 VLANs
Date: Thu, 22 Jul 2010 14:12:59 -0700 (PDT)
Message-ID: <20100722.141259.262780053.davem@davemloft.net>
References: <1279750488-32611-1-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pedro.netdev@dondevamos.com,
	kaber@trash.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759329Ab0GVVMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:12:43 -0400
In-Reply-To: <1279750488-32611-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 21 Jul 2010 15:14:47 -0700

> 	After commit:
> 
> commit ad1afb00393915a51c21b1ae8704562bf036855f
> Author: Pedro Garcia <pedro.netdev@dondevamos.com>
> Date:   Sun Jul 18 15:38:44 2010 -0700
> 
>     vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p packet)
> 
> 	it is now regular practice for a VLAN "add vid" for VLAN 0 to
> arrive prior to any VLAN registration or creation of a vlan_group.
> 
> 	This patch updates the bonding code that tests for the presence
> of VLANs configured above bonding.  The new logic tests for bond->vlgrp
> to determine if a registration has occured, instead of testing that
> bonding's internal vlan_list is empty.
> 
> 	The old code would panic when vlan_list was not empty, but
> vlgrp was still NULL (because only an "add vid" for VLAN 0 had occured).
> 
> 	Bonding still adds VLAN 0 to its internal list so that 802.1p
> frames are handled correctly on transmit when non-VLAN accelerated
> slaves are members of the bond.  The test against bond->vlan_list
> remains in bond_dev_queue_xmit for this reason.
> 
> 	Modification to the bond->vlgrp now occurs under lock (in
> addition to RTNL), because not all inspections of it occur under RTNL.
> 
> 	Additionally, because 8021q will never issue a "kill vid" for
> VLAN 0, there is now logic in bond_uninit to release any remaining
> entries from vlan_list.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
