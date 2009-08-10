From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [PATCH net-next-2.6] net: Changes to support the "-f" option
	of ethtool.
Date: Mon, 10 Aug 2009 14:34:05 +0530
Message-ID: <20090810090404.GA16575@serverengines.com>
References: <20090805123211.GB6592@serverengines.com> <20090805123704.GC6592@serverengines.com> <1249477567.2781.21.camel@achroite> <20090805.131723.120803503.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:41316 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752678AbZHJJEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 05:04:06 -0400
Content-Disposition: inline
In-Reply-To: <20090805.131723.120803503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/09 13:17 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 05 Aug 2009 14:06:07 +0100
> 
> > request_firmware() is meant for loading firmware that is stored in
> > volatile memory (RAM) on the device and therefore needs to be installed
> > on the host.
> > 
> > When the firmware is stored in flash on the device, updates only need to
> > be used once, and there should be no need to install them on the host.
> > So request_firmware() does not seem suitable.
> > 
> > I believe the ethtool EEPROM commands were meant for updating firmware
> > on NICs.  Although they assume random access and so are unsuitable for
> > flash-based firmware, they might be a better model for adding flash
> > update commands.  However, this command set is already available through
> > the MTD device class, which is what we use for firmware update as far as
> > possible.  Not only does this allow for an arbitrary number of separate
> > firmware partitions per network device, but it can be used in an
> > out-of-tree driver for older kernel versions.
> 
> I mostly agree with this.  Either use MTD or create an ethtool
> operation that explicitly specifies the file to flash onto the
> chip.  If you want, I suppose you can take no explicit file
> specification to mean "whatever firmware was loaded into the
> chip by the driver and is running right now"
Thanks. I will go with the ethtool option which would also take the 
filename and flash it onto the chip using the request_firmware() path.

-Ajit
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
