From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH 1/2] sfc: Use kernel I2C system and i2c-algo-bit driver
Date: Sat, 31 May 2008 17:07:40 +0200
Message-ID: <20080531170740.5f4606c5@hyperion.delvare>
References: <cover.1212182201.git.bhutchings@solarflare.com>
	<20080530212703.GG1743@solarflare.com>
	<20080531131848.24b9e465@hyperion.delvare>
	<20080531112700.GL1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:22015 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbYEaPH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 11:07:59 -0400
In-Reply-To: <20080531112700.GL1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 May 2008 12:27:02 +0100, Ben Hutchings wrote:
> Jean Delvare wrote:
> > > @@ -2459,6 +2475,18 @@ int falcon_probe_nic(struct efx_nic *efx)
> > >  	if (rc)
> > >  		goto fail5;
> > >  
> > > +	/* Initialise I2C adapter */
> > > + 	efx->i2c_adap.owner = THIS_MODULE;
> > > + 	efx->i2c_adap.class = I2C_CLASS_HWMON;
> > 
> > I doubt you want to do this. This would let any hardware monitoring
> > driver probe your bus for a device, while presumably you already know
> > which hardware monitoring device is present and you want to instantiate
> > the i2c client yourself. This will probably become clearer when you
> > start using the lm87 driver and modify it to support new-style i2c
> > binding.
>  
> So the class should be, what, 0?

Yes. Assuming a kzalloc'd structure, you can simply omit it.

> > > +	nic_data->i2c_data = falcon_i2c_bit_operations;
> > > +	nic_data->i2c_data.data = efx;
> > > + 	efx->i2c_adap.algo_data = &nic_data->i2c_data;
> > > +	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
> > > +	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");
> > 
> > Please always use strlcpy.
>  
> OK.  I thought about it but it didn't seem worthwhile for a short constant
> string.

Until someone changes the string for a longer one (it's common to
include the I/O base) or the structure field is shortened to save some
memory... Always use strlcpy. In fact I'd like to see strcpy removed
from the kernel, it's almost always the wrong function to use.

-- 
Jean Delvare
