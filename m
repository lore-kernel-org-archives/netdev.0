From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: Re: [PATCH 2/2] au1000-eth: convert to platform_driver model
Date: Wed, 11 Nov 2009 13:00:23 +0100
Message-ID: <f861ec6f0911110400g105e6a2j3666f32c7cb7bc85@mail.gmail.com>
References: <200911100113.38685.florian@openwrt.org>
	 <f861ec6f0911100120j12d86b0cs3ef9c2816019eaf9@mail.gmail.com>
	 <200911111254.16500.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:44225 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbZKKMAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 07:00:20 -0500
Received: by fxm21 with SMTP id 21so913076fxm.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 04:00:24 -0800 (PST)
In-Reply-To: <200911111254.16500.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2009 at 12:54 PM, Florian Fainelli <florian@openwrt.org=
> wrote:
> Hi Manuel,
>
> On Tuesday 10 November 2009 10:20:25 Manuel Lauss wrote:
>> Hi Florian,
>>
>> On Tue, Nov 10, 2009 at 1:13 AM, Florian Fainelli <florian@openwrt.o=
rg>
> wrote:
>> > This patch converts the au1000-eth driver to become a full
>> > platform-driver as it ought to be. We now pass PHY-speficic
>> > configurations through platform_data but for compatibility
>> > the driver still assumes the default settings (search for PHY1 on
>> > MAC0) when no platform_data is passed. Tested on my MTX-1 board.
> [snip]
>> >
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =3D tmp_phyde=
v;
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; /* found it *=
/
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (aup->phy1_search_mac0) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* try harder to fin=
d a PHY */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!phydev && (aup-=
>mac_id =3D=3D 1)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* n=
o PHY found, maybe we have a dual
>> > PHY? */ + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 printk (KERN_INFO DRV_NAME ": no
>> > PHY found on MAC1, " + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "let's see
>> > if it's attached to MAC0...\n"); +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* f=
ind the first (lowest address)
>> > non-attached PHY on + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0* the MAC0 MII bus
>> > */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for =
(phy_addr =3D 0; phy_addr <
>> > PHY_MAX_ADDR; phy_addr++) { + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if
>> > (aup->mac_id =3D=3D 1)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> aup->mac_id needs to be 1 for this loop to be executed in the first
>> place, and here
>> you immediately bail out if it is.
>
> From the reading of the comment, it seems to me like we should not do=
 anything
> in this for loop if we were using MAC1, but I may have misunderstood =
that, as
> such I have added this break to "comply" with the comment.
>
>> Also, how do you access the phy map of the other controller without =
use of
>> =A0the au_macs[] structure? (which is unused after this patch and co=
uld be
>> =A0removed, along
>> with the NUM_ETH_INTERFACES constant)
>
> We access the phy map of the other controller by using the correct mi=
i bus
> identifier, since we have registered a per-interface mdio bus or have=
 I
> overlooked something ?

Don't know, that's why I asked.


>>
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct phy_device *const
>> > tmp_phydev =3D +
>> > aup->mii_bus->phy_map[phy_addr];
>>
>> My compiler complains about mixed code/declarations.
>
> That declaration was already there and as this patch has no intent to=
 clean
> anything right now, I have left it as-is.

The "if (aup->mac_id =3D=3D 1)" you inserted before it causes it.

You're right though in that there's some cleanup potential after this
patch has gone in...

      Manuel Lauss
