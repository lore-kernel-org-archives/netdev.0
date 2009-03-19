From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 5/5] net: make mpc5200 fec driver use of_mdio
	infrastructure
Date: Wed, 18 Mar 2009 22:35:14 -0600
Message-ID: <fa686aa40903182135v51bbeafahc7fa899fb454a312@mail.gmail.com>
References: <20090310150751.12455.70598.stgit@localhost.localdomain>
	 <20090310152224.12455.99348.stgit@localhost.localdomain>
	 <20090310191638.GA8539@oksana.dev.rtsoft.ru>
	 <fa686aa40903101248n33ee35c2o32c4b24b349b14fc@mail.gmail.com>
	 <20090310202949.GA17184@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:26067 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbZCSEfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 00:35:16 -0400
In-Reply-To: <20090310202949.GA17184@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 2:29 PM, Anton Vorontsov
<avorontsov@ru.mvista.com> wrote:
> On Tue, Mar 10, 2009 at 01:48:26PM -0600, Grant Likely wrote:
>> Regardless, I
>> think all the drivers should be using common code for obtaining the
>> phy_device from the device tree.
>
> Not necessary `struct phy_device'. All we need is some common
> routine for translating PHY's "mdio_node->full_name + phy id" to
> phy_bus_id.

This only works if the network driver knows how the MDIO bus is named.
 The current code assumes that the MDIO bus name is the register
address, but this is a driver implementation detail and MDIO bus
drivers can deviate from this.  What about MDIO busses that don't have
a reg property?  For example, fs_enet/mii-bitbang.c sets the bus name
to "CPM2 Bitbanged MII".  There is no one-size-fits-all way to figure
out the phy bus id from the ethernet driver side of things.

The sure and simple way to guarantee a match between the PHY device
node and the phy_device is to use the PHY device_node pointer itself
as the search key.

I concede that my first attempt at this was overly complex, but I've
reworked the code and I think it makes thinks considerably simpler.
I'll post a new series tomorrow.  I've got patches to make the
ucc_eth, gianfar and fs_enet drivers to use the device_node method
also.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
