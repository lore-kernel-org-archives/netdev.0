From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 1/3] ixgbe: Add hardware specific
	initialization code for 82599 devices
Date: Sat, 28 Feb 2009 02:37:27 +0000
Message-ID: <1235788647.3576.4.camel@hashbaz.i.decadent.org.uk>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
	 <20090228014430.22664.79867.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3818 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752196AbZB1Chg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 21:37:36 -0500
In-Reply-To: <20090228014430.22664.79867.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-02-27 at 17:44 -0800, Jeff Kirsher wrote:
[...]
> diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
> index 77ec26f..14e9606 100644
> --- a/drivers/net/ixgbe/ixgbe_phy.c
> +++ b/drivers/net/ixgbe/ixgbe_phy.c
[...]
> @@ -688,6 +755,501 @@ s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
>  }
>  
>  /**
> + *  ixgbe_read_i2c_eeprom_generic - Reads 8 bit EEPROM word over I2C interface
> + *  @hw: pointer to hardware structure
> + *  @byte_offset: EEPROM byte offset to read
> + *  @eeprom_data: value read
> + *
> + *  Performs byte read operation to SFP module's EEPROM over I2C interface.
> + **/
> +s32 ixgbe_read_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
> +                                  u8 *eeprom_data)
> +{
> +	return hw->phy.ops.read_i2c_byte(hw, byte_offset,
> +	                                 IXGBE_I2C_EEPROM_DEV_ADDR,
> +	                                 eeprom_data);
> +}
> +
> +/**
> + *  ixgbe_write_i2c_eeprom_generic - Writes 8 bit EEPROM word over I2C interface
> + *  @hw: pointer to hardware structure
> + *  @byte_offset: EEPROM byte offset to write
> + *  @eeprom_data: value to write
> + *
> + *  Performs byte write operation to SFP module's EEPROM over I2C interface.
> + **/
> +s32 ixgbe_write_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
> +                                   u8 eeprom_data)
> +{
> +	return hw->phy.ops.write_i2c_byte(hw, byte_offset,
> +	                                  IXGBE_I2C_EEPROM_DEV_ADDR,
> +	                                  eeprom_data);
> +}
> +
> +/**
> + *  ixgbe_read_i2c_byte_generic - Reads 8 bit word over I2C
> + *  @hw: pointer to hardware structure
> + *  @byte_offset: byte offset to read
> + *  @data: value read
> + *
> + *  Performs byte read operation to SFP module's EEPROM over I2C interface at
> + *  a specified deivce address.
> + **/
[...]

You should be registering an I2C adapter and using the I2C bit-bang
algorithm for this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

