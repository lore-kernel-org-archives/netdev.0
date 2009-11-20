From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: [RFC] p54: software hot-swap eeprom image
Date: Fri, 20 Nov 2009 22:32:43 +0200
Message-ID: <87tywpaqdw.fsf@purkki.valot.fi>
References: <200911202027.13284.chunkeey@googlemail.com>
	<1258746786.26965.83.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:50973 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484AbZKTUck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:32:40 -0500
In-Reply-To: <1258746786.26965.83.camel@localhost.localdomain> (Dan Williams's message of "Fri\, 20 Nov 2009 11\:53\:06 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

> On Fri, 2009-11-20 at 20:27 +0100, Christian Lamparter wrote:
>> This (aggregated) patch adds a new sysfs file "eeprom_overwrite"
>> which can be used to upload an customized eeprom image to the
>> driver during normal operation.

[...]

> Honestly I wonder if this would be better done with ethtool.  There's
> already ethtool --eeprom-dump, would it be so hard to do an ethtool
> --eeprom-load ?
>
> I can see a number of devices doing this, so in my mind it makes sense
> to have a generic facility for this sort of thing.  But then again it's
> not so common an operation and its fraught with danger :)

I think that devices without eeprom at all (eg. stlc4550, most wl1251
and all wl1271 chips) request_firmware() and a udev script is the best
way to go, as they will need the eeprom data from user space during
every boot. This was discussed few months back, but unfortunately I
have yet to seen an implementation of this :) Hopefully I find some
time to try this soon.

But for devices with eeprom, having support in ethtool sounds good to
me.

> Libertas could potentially use this, but libertas has *two* EEPROM
> images that it might need to update. So if ethtool did grow
> --eeprom-load we may want to account for more than one eeprom image.

Makes sense to mee.

-- 
Kalle Valo
