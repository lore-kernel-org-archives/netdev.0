From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 00:56:46 -0800 (PST)
Message-ID: <20090305.005646.115456407.davem@davemloft.net>
References: <49AF7FD3.5010709@trash.net>
	<49AF87D6.5040104@linux.vnet.ibm.com>
	<49AF8CE0.6030301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, bart@jukie.net,
	greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60690
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751305AbZCEI5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 03:57:01 -0500
In-Reply-To: <49AF8CE0.6030301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Mar 2009 09:27:12 +0100

> Frank Blaschka wrote:
> > Hi Dave, Patrick,
> >
> > sorry I could not follow the complete discussion of the fixes done for this problem
> > but does
> >
> >  	if (netif_device_present(real_dev) && ops->ndo_neigh_setup)
> > -		err = ops->ndo_neigh_setup(dev, pa);
> > +		err = ops->ndo_neigh_setup(real_dev, pa);
> >
> > not change the idea of the neigh_setup? Remind we want the neigh_setup of the
> > real device as the neigh setup function for the vlan device.
> >   
> 
> An we still use it. The only difference is that we pass it the
> correct device reference, which not only fixes the recursion,
> but is also expected by the callbacks. Look at bonding or simply
> vlan itself.
> 
> The setup itself is still done using the neigh_params passed to
> VLAN, which appears to be what was originally intended.

Then bond_neigh_setup() has the same bug, doesn't it?
