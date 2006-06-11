From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [RFC ] [1 of 4] IEEE802.11 Regulatory/Geographical Support for drivers - statement of project
Date: Sun, 11 Jun 2006 12:07:50 +0200
Message-ID: <20060611100750.GF24167@p15091797.pureserver.info>
References: <448210EF.10103@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:35040 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750898AbWFKKHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 06:07:51 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <448210EF.10103@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry,

I've not read your patches your detail, so I comment only on your
description.

> 1. A new routine, ieee80211_init_geo has been written that is called by a 
> driver wishing to use this functionality. The arguments are an 
> ieee80211_device, a two-character ISO3661 country code, and a flag that is 
> true if the device is to be used outdoors. This new routine does the 
> following:

The problem is the driver doesn't have good ideas, whether the
device is outdoor and in which country it operates. Devices have
some information available, but I have definitely a device
marketed in Canada, which had an EEPROM value for ETSI as
regulatory domain. I would expect the daemon to know, in which
country it is and whether the device is used outdoors. Keep also
in mind, that this information will be available from the AP at a
later time.

So there should be an explicit method to request the minimum set
or the configuration of daemon. Later the set can be changed again
by the AP information provided.

>   b) It then creates a new directory, '/proc/net/ieee80211_geo', and 
>   populates it with 2 files for communication with the daemon. The first, 
> which is read by the daemon, contains the country and outdoor codes, and 
> the second is for the the daemon to write the 'struct ieee80211_geo' data 
> corresponding to the country and indoor/outdoor information passed from the 
> kernel.

Michael Buesch already commented on /proc/net. I don't think, that
this will be popular with a lot of folks. sysfs should be
supported and the mechanism should be comparable to firmware
loading. Maybe this could be some kind of udev extension. And make
it device specific, the whole approach should not break, if you
are accessing two devices connecting to two different access
points at the same time, where one of them is configured by the
central networking folks, who don't bother to adapt there configs
to specific countries and the other is a perfectly conformant
local AP, which is used for "testing" purposes.

> 2. The user-space daemon, which need not be run as root, does the following:

It needs only to run temporarily run as root. I would definitely
recommend that all file parsing activities should not run as root.

>   e) It then spins waiting for the existence of file 
>   '/proc/net/ieee80211_geo/country', which is the indication that the kernel 
> is requesting data.

Again the whole interface should be device specific. 

> I welcome your comments. Part 2 will show a debug dump of the converted 
> database, Part 3 will present the patch needed to add the new routine to 
> the ieee80211 routines, and Part 4 will show the patches needed to modify 
> the bcm43xx driver to use the new routine..

Cheers, 

Uli

-- 
Uli Kunitz
