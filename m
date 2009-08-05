From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: Changes to support the "-f" option
	of ethtool.
Date: Wed, 05 Aug 2009 14:06:07 +0100
Message-ID: <1249477567.2781.21.camel@achroite>
References: <20090805123211.GB6592@serverengines.com>
	 <20090805123704.GC6592@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:35116 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933713AbZHENGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 09:06:15 -0400
In-Reply-To: <20090805123704.GC6592@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-05 at 18:07 +0530, Ajit Khaparde wrote:
> The patch intends to use the request_firmware() interface to pick the
> firmware image file. 
> I had missed this in the original post. Thanks.
[...]

Thanks for the clarification.

request_firmware() is meant for loading firmware that is stored in
volatile memory (RAM) on the device and therefore needs to be installed
on the host.

When the firmware is stored in flash on the device, updates only need to
be used once, and there should be no need to install them on the host.
So request_firmware() does not seem suitable.

I believe the ethtool EEPROM commands were meant for updating firmware
on NICs.  Although they assume random access and so are unsuitable for
flash-based firmware, they might be a better model for adding flash
update commands.  However, this command set is already available through
the MTD device class, which is what we use for firmware update as far as
possible.  Not only does this allow for an arbitrary number of separate
firmware partitions per network device, but it can be used in an
out-of-tree driver for older kernel versions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

