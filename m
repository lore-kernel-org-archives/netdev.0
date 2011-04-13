From: Andy Fleming <afleming@gmail.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured
 incorrectly in fiber mode
Date: Wed, 13 Apr 2011 13:01:10 -0500
Message-ID: <BANLkTikH09jMZZk1ZgeQi+HOoeFqgTpdBA@mail.gmail.com>
References: <4DA3703B.1090802@caviumnetworks.com>
	<392488.26736.qm@web37606.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Daney <ddaney@caviumnetworks.com>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:52116 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057Ab1DMSBK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:01:10 -0400
Received: by pzk9 with SMTP id 9so308525pzk.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 11:01:10 -0700 (PDT)
In-Reply-To: <392488.26736.qm@web37606.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 10:45 PM, Alex Dubov <oakad@yahoo.com> wrote:
>>
>> How does your u-boot configure the part?=A0 Does it
>> write any of the
>> configuration registers, or is it just the default
>> configuration set via
>> the strapping pins?
>
> U-boot configures this phy just like any other phy - by running a set=
 of
> register assignments from phy_info_M88E1145.
>
> Unfortunately, I don't have a datasheet for this phy and kernel does
> quite a few things differently, so simply copying stuff from u-boot
> does not work well (in kernel, phy initialization is broken into 3
> functions, if I'm not mistaken).

I've just rewritten the U-Boot code for PHY management, so I'd be
interested in hearing if this breaks your board.  But what's
interesting to me is that, in order for U-Boot to report that the link
is a "fiber" link, something had to set the TSEC_FIBER flag, and only
one PHY in the public source did.  This implies to me that your board
isn't supported by mainline U-Boot, and suggests that someone may have
modified the 88e1145 driver. Otherwise, I don't see any fiber-related
differences between the U-Boot 1145 driver, and the Linux one.


>
>
>>
>> In any event, you will probably have to read the
>> configuration before
>> the drivers/net/phy/marvel.c changes them.=A0 Then
>> compare that to what
>> the driver is trying to set.=A0 Then you will either
>> have to override the
>> configuration with the device tree "marvell,reg-init"
>> property, or if
>> you are not using the device tree, add a 88e1145 specific
>> flag that you
>> set when calling phy_connect().


Reading the configuration from U-Boot is straightforward.  use the
"mii" command to read the registers.  But don't forget to set register
22 (16 - mii command only reads hex) to 1, and read all of the
registers that way, too.

You will either need to add some code to detect when the PHY is using
fiber, and change the phydev->port to PORT_FIBRE, or you will need to
add a board-level "fixup" to change the port to PORT_FIBRE on your
board.

Then the PHY driver should use that information to do the right configu=
ration.

Andy
