From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next PATCH 1/3] ixgbe: Add hardware specific	initialization
 code for 82599 devices
Date: Fri, 27 Feb 2009 20:58:29 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0902272052320.2284@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
 <20090228014430.22664.79867.stgit@lost.foo-projects.org>
 <1235788647.3576.4.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7796 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144AbZB1E6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 23:58:34 -0500
In-Reply-To: <1235788647.3576.4.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2009, Ben Hutchings wrote:

> On Fri, 2009-02-27 at 17:44 -0800, Jeff Kirsher wrote:
> [...]
> > diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
> > index 77ec26f..14e9606 100644
> > --- a/drivers/net/ixgbe/ixgbe_phy.c
> > +++ b/drivers/net/ixgbe/ixgbe_phy.c
> [...]
> > @@ -688,6 +755,501 @@ s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
> >  }
> >  
> >  /**
> > + *  ixgbe_read_i2c_eeprom_generic - Reads 8 bit EEPROM word over I2C interface
> > + *  @hw: pointer to hardware structure
> > + *  @byte_offset: EEPROM byte offset to read
> > + *  @eeprom_data: value read
> > + *
> > + *  Performs byte read operation to SFP module's EEPROM over I2C interface.
> > + **/
> > +s32 ixgbe_read_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
> > +                                  u8 *eeprom_data)
> > +{
> > +	return hw->phy.ops.read_i2c_byte(hw, byte_offset,
> > +	                                 IXGBE_I2C_EEPROM_DEV_ADDR,
> > +	                                 eeprom_data);
> > +}
> > +
> > +/**
> > + *  ixgbe_write_i2c_eeprom_generic - Writes 8 bit EEPROM word over I2C interface
> > + *  @hw: pointer to hardware structure
> > + *  @byte_offset: EEPROM byte offset to write
> > + *  @eeprom_data: value to write
> > + *
> > + *  Performs byte write operation to SFP module's EEPROM over I2C interface.
> > + **/
> > +s32 ixgbe_write_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
> > +                                   u8 eeprom_data)
> > +{
> > +	return hw->phy.ops.write_i2c_byte(hw, byte_offset,
> > +	                                  IXGBE_I2C_EEPROM_DEV_ADDR,
> > +	                                  eeprom_data);
> > +}
> > +
> > +/**
> > + *  ixgbe_read_i2c_byte_generic - Reads 8 bit word over I2C
> > + *  @hw: pointer to hardware structure
> > + *  @byte_offset: byte offset to read
> > + *  @data: value read
> > + *
> > + *  Performs byte read operation to SFP module's EEPROM over I2C interface at
> > + *  a specified deivce address.
> > + **/
> [...]
> 
> You should be registering an I2C adapter and using the I2C bit-bang
> algorithm for this.

Thanks for the comments Ben.  Early on, we looked at doing this.  The 
reality though for us is this code (the PHY code, among others) is shared 
between our drivers across different platforms.  So the reason we didn't 
use the in-kernel I2C library is nobody else would have been able to use the 
code.  But that doesn't really apply to this driver; just wanted to give 
background why this is the way it is in the post.

That being said, I will look at the I2C kernel interfaces this weekend and 
see how I can fit it in here.

Cheers,
-PJ Waskiewicz
