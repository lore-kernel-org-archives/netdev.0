From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 2/2] net: dsa: introduce MICREL
	KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 22:31:37 +0200
Message-ID: <AANLkTiljQD8CIBtHcMqXdGQILCLDsU-6brjdWB2yB_mN@mail.gmail.com>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<1279719442-10174-2-git-send-email-vapier@gentoo.org>
	<20100721151608.GM21121@mail.wantstofly.org>
	<AANLkTinoVsz1YsWc3VSAqPPgH_L19B541A72zkWPxjM8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52156 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab0GUUbi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:31:38 -0400
Received: by wyf19 with SMTP id 19so8706wyf.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:31:37 -0700 (PDT)
In-Reply-To: <AANLkTinoVsz1YsWc3VSAqPPgH_L19B541A72zkWPxjM8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 6:05 PM, Mike Frysinger <vapier.adi@gmail.com> =
wrote:
> On Wed, Jul 21, 2010 at 11:16, Lennert Buytenhek wrote:
>> On Wed, Jul 21, 2010 at 09:37:22AM -0400, Mike Frysinger wrote:
>>> +static int ksz8893m_setup(struct dsa_switch *ds)
>>> +{
>>> + =A0 =A0 int i;
>>> + =A0 =A0 int ret;
>>> +
>>> + =A0 =A0 ret =3D ksz8893m_switch_reset(ds);
>>> + =A0 =A0 if (ret < 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>>
>> It's pretty ugly that the mdiobus is passed in via the normal means,
>> but a reference to the SPI bus to use is just stuffed into some glob=
al
>> variable.
>>
>> Can you not access all registers via MII?
>
> it depends on the host mdio bus. =A0if it supports the semi-standard
> behavior of toggling the OP field of MDIO frames, then yes, you can d=
o
> it via MII. =A0but i dont think the current mdio framework in the ker=
nel
> keeps track of that functionality, so there isnt a way in the driver
> to say "is this possible, else fall back to SPI".
>
Are you referring to SMI ?

> certainly the part that was used to develop this driver does not
> support this behavior thus SPI is the only way of accessing the
> extended registers. =A0i guess the driver could be extended so that
> people could pick which mode they want to program the registers via
> platform resources, but we have no way of testing that, so i say let
> the person who actually can use & wants that functionality implement
> it.
>
>> (If not, struct dsa_chip_data will need go be extended with another
>> struct device pointer that we can use to find the spi bus with.)
>
> if the framework supports, i can convert the driver to it, but i'm no=
t
> sure we have the time atm to tackle reworking common frameworks.
>
If someone tackles this, it would be nice that they bear in mind that
phylib's drivers also need spi/smi/i2c register access.

>>> +static int ksz8893m_port_to_phy_addr(int port)
>>> +{
>>> + =A0 =A0 if (port >=3D 1 && port <=3D KSZ8893M_PORT_NUM)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return port;
>>> +
>>> + =A0 =A0 pr_warning("use default phy addr 3\n");
>>> + =A0 =A0 return 3;
>>
>> Does this ever happen? =A0You should just be able to return -1 here,=
 IMHO.
>
> i dont recall seeing a warning, but presumably if it it did occur,
> something else needs fixing. =A0so -1 is OK.
>
I would remove this.

--=20
Karl
