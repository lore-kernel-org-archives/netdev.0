From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Changes to support the "-f" option
 of ethtool.
Date: Wed, 05 Aug 2009 13:17:23 -0700 (PDT)
Message-ID: <20090805.131723.120803503.davem@davemloft.net>
References: <20090805123211.GB6592@serverengines.com>
	<20090805123704.GC6592@serverengines.com>
	<1249477567.2781.21.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751400AbZHEURO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 16:17:14 -0400
In-Reply-To: <1249477567.2781.21.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 05 Aug 2009 14:06:07 +0100

> request_firmware() is meant for loading firmware that is stored in
> volatile memory (RAM) on the device and therefore needs to be installed
> on the host.
> 
> When the firmware is stored in flash on the device, updates only need to
> be used once, and there should be no need to install them on the host.
> So request_firmware() does not seem suitable.
> 
> I believe the ethtool EEPROM commands were meant for updating firmware
> on NICs.  Although they assume random access and so are unsuitable for
> flash-based firmware, they might be a better model for adding flash
> update commands.  However, this command set is already available through
> the MTD device class, which is what we use for firmware update as far as
> possible.  Not only does this allow for an arbitrary number of separate
> firmware partitions per network device, but it can be used in an
> out-of-tree driver for older kernel versions.

I mostly agree with this.  Either use MTD or create an ethtool
operation that explicitly specifies the file to flash onto the
chip.  If you want, I suppose you can take no explicit file
specification to mean "whatever firmware was loaded into the
chip by the driver and is running right now"

