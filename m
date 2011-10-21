From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [RFC PATCH 15/17] phy_device: Add "port" and "transciever" fields
Date: Fri, 21 Oct 2011 03:12:53 -0400
Message-ID: <CAGZ=bqKMGnf1SaPHrgaNYTaaq-axA-1bbOWeZfThwZgWUy8weA@mail.gmail.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-16-git-send-email-Kyle.D.Moffett@boeing.com> <1319153279.2918.16.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	David Decotigny <decot@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mike Frysinger <vapier@gentoo.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319153279.2918.16.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 19:27, Ben Hutchings <bhutchings@solarflare.com=
> wrote:
> On Thu, 2011-10-20 at 17:00 -0400, Kyle Moffett wrote:
>> Some PHYs have multiple software-selectable inputs and outputs,
>> including RGMII, SGMII, SerDes, etc. =C2=A0New fields are added to t=
he
>> "struct phy_device" for "port" and "transciever" to allow "ethtool" =
to
>> switch outputs at runtime. =C2=A0The defaults for the new fields are
>> identical to the hardcoded values used previously.
>>
>> This should make no functional changes to the PHY layer behavior, bu=
t
>> it will allow later PHY/ethernet drivers to override those fields.
>>
>> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
>> ---
>> =C2=A0drivers/net/phy/phy.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0=
4 ++--
>> =C2=A0drivers/net/phy/phy_device.c | =C2=A0 =C2=A02 ++
>> =C2=A0include/linux/phy.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A04 ++++
>> =C2=A03 files changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index c378f91..5f72055 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -290,9 +290,9 @@ int phy_ethtool_gset(struct phy_device *phydev, =
struct ethtool_cmd *cmd)
>>
>> =C2=A0 =C2=A0 =C2=A0 ethtool_cmd_speed_set(cmd, phydev->speed);
>> =C2=A0 =C2=A0 =C2=A0 cmd->duplex =3D phydev->duplex;
>> - =C2=A0 =C2=A0 cmd->port =3D PORT_MII;
>> + =C2=A0 =C2=A0 cmd->port =3D phydev->port;
>> =C2=A0 =C2=A0 =C2=A0 cmd->phy_address =3D phydev->addr;
>> - =C2=A0 =C2=A0 cmd->transceiver =3D XCVR_EXTERNAL;
>> + =C2=A0 =C2=A0 cmd->transceiver =3D phydev->transciever;
>
> 'transceiver' is spelt thus.

Oh shoot!

That's what I get for trying to do a last-minute patch edit before
sending the email; thanks for pointing it out!

Cheers,
Kyle Moffett

--=20
Curious about my work on the Debian powerpcspe port?
I'm keeping a blog here: http://pureperl.blogspot.com/
