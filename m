From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured incorrectly
 in fiber mode
Date: Tue, 12 Apr 2011 09:34:14 -0700
Message-ID: <4DA47F06.7020803@caviumnetworks.com>
References: <392488.26736.qm@web37606.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17337 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445Ab1DLQeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:34:20 -0400
In-Reply-To: <392488.26736.qm@web37606.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2011 08:45 PM, Alex Dubov wrote:
>>
>> How does your u-boot configure the part?  Does it
>> write any of the
>> configuration registers, or is it just the default
>> configuration set via
>> the strapping pins?
>
> U-boot configures this phy just like any other phy - by running a set of
> register assignments from phy_info_M88E1145.
>
> Unfortunately, I don't have a datasheet for this phy

I would guess that the people who designed your board have it.

You do seem to have the uboot code though, so you know which registers 
are being set.  Given this, you can fiddle around with the Linux driver 
until it works.  Then send a patch.

To me it looks like you need to set register 22 (Page Select) to the 
value of 1 to access the register sets associated with fiber.  I don't 
have any hardware with this PHY connected to fiber, so I can't really 
test it.

David Daney

> and kernel does
> quite a few things differently, so simply copying stuff from u-boot
> does not work well (in kernel, phy initialization is broken into 3
> functions, if I'm not mistaken).
>
> Otherwise, my problem seems to be identical to the one reported some
> time ago against 88E1111 phy (which resulted in the addition of
> "marvell_read_status" in the first place). The problem was, as it seems
> to be now, that phy is always configured in "copper" mode, instead of
> driver checking for the correct "fiber" mode bits.
>
>
>>
>> In any event, you will probably have to read the
>> configuration before
>> the drivers/net/phy/marvel.c changes them.  Then
>> compare that to what
>> the driver is trying to set.  Then you will either
>> have to override the
>> configuration with the device tree "marvell,reg-init"
>> property, or if
>> you are not using the device tree, add a 88e1145 specific
>> flag that you
>> set when calling phy_connect().
>>
>> David Daney
>>

