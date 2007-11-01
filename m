From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Thu, 1 Nov 2007 16:07:09 -0500
Message-ID: <20071101160709.7e7c0181@weaponx.rchland.ibm.com>
References: <200711011554.04935.sr@denx.de>
	<1193949421.6541.10.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35232 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbXKAVHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:07:16 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA1L7F87016893
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 17:07:15 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1L7CZI081556
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 15:07:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1L7B2V000845
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 15:07:11 -0600
In-Reply-To: <1193949421.6541.10.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Nov 2007 07:37:01 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Thu, 2007-11-01 at 15:54 +0100, Stefan Roese wrote:
> > This patch adds support for the 405EX to the new EMAC driver.
> > 
> > Tested on AMCC Kilauea.
> 
>  .../...
> 
> > diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
> > index de41695..e393f68 100644
> > --- a/drivers/net/ibm_newemac/rgmii.c
> > +++ b/drivers/net/ibm_newemac/rgmii.c
> > @@ -140,9 +140,6 @@ void rgmii_get_mdio(struct of_device *ofdev, int input)
> >  
> >  	RGMII_DBG2(dev, "get_mdio(%d)" NL, input);
> >  
> > -	if (dev->type != RGMII_AXON)
> > -		return;
> > -
> >  	mutex_lock(&dev->lock);
> 
> That will break 440GX boards that need to use the RGMII for data and the
> ZMII for MDIO.
> 
> You may want to change the name RGMII_AXON something like RGMII_HAS_MDIO
> instead and set that for 405EX as well instead.

And perhaps adding a comment about that since the meaning of that code
isn't very obvious. That way people that aren't the original author
of the driver don't get confused again.

josh
