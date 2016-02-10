From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Micrel PHY and power down mode
Date: Wed, 10 Feb 2016 14:10:32 -0800
Message-ID: <56BBB558.3010205@gmail.com>
References: <ea1cb242a247bc6665947ab9a77cb454@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan Agner <stefan@agner.ch>, david.choi@micrel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33118 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbcBJWLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:11:37 -0500
Received: by mail-pa0-f43.google.com with SMTP id fl4so6491621pad.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 14:11:37 -0800 (PST)
In-Reply-To: <ea1cb242a247bc6665947ab9a77cb454@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

On 10/02/16 11:25, Stefan Agner wrote:
> Hi David, Hi Florian,
>=20
> We use a Micrel KSZ8041NL and we observe sometimes continuous RX erro=
rs
> (PHY's RXER counter is continuously incrementing, activity LED blinks
> and no communication is possible). It seems that only some PHY's are
> affected (3-4%) and only in certain temperature ranges (the PHY I can
> reproduce the issue here shows the problem ~30=C2=B0C). We could narr=
ow the
> issue down, and realized that the problem only appears after the PHY =
has
> been in power down mode. Since Linux calls suspend/resume when
> attaching/detaching the PHY, a simple ifup/ifdown bascially can trigg=
er
> the issue.
>=20
> Currently, the wakeup sequence writes the following registers
> 0x8000 to 0x00 (phy_attach_direct -> phy_init_hw -> genphy_soft_reset=
)
> 0x3000 to 0x00 (phy_attach_direct -> genphy_resume)
>=20
> I am not sure if this sequence is really ok. It seems to me that
> genphy_soft_reset clears the power down bit already, which makes
> genphy_resume somewhat useless. However, altering the behavior of
> genphy_soft_reset to not clear the power down bit (yet) did not resol=
ve
> the issue.

AFAIR, issuing a BMCR reset, with a PHY which was in power down should
clear the power down bit, but I would not be surprised if some PHYs wer=
e
not quite behaving like that though.

>=20
> Is clearing the power down bit and generating the reset in one go
> intended? I checked the datasheet, and did not found particular
> information about the "resume" sequence...=20

Does it help if your PHY resume callback does the same thing as what th=
e
config_init() does? You have the ability to skip the generic software
reset of the PHY via BMCR bit 15, and instead do nothing by implementin=
g
your own soft_reset() callback, that might tell you whether the softwar=
e
reset is what is screwing things up?

Getting some insight from somebody at Micrel would definitively help
with understanding what a workaround or fix would look like.

HTH
--=20
=46lorian
