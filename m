From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 4.1 11/56] mvneta: add forgotten initialization of
 autonegotiation bits
Date: Wed, 8 Jul 2015 21:36:46 +0300
Message-ID: <559D6DBE.4040900@list.ru>
References: <20150708073237.780280770@linuxfoundation.org>
 <20150708073238.389781888@linuxfoundation.org> <559D5996.5080506@list.ru>
 <20150708173655.GA16101@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Sebastien Rannou <mxs@sbrk.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150708173655.GA16101@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

08.07.2015 20:36, Greg Kroah-Hartman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, Jul 08, 2015 at 08:10:46PM +0300, Stas Sergeev wrote:
>> 08.07.2015 10:35, Greg Kroah-Hartman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> 4.1-stable review patch.  If anyone has any objections, please let =
me know.
>>>
>>> ------------------
>>>
>>> From: Stas Sergeev <stsp@list.ru>
>>>
>>> [ Upstream commit 538761b794c1542f1c6e31eadd9d7aae118889f7 ]
>>>
>>> The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band lin=
k state
>>> signaling")
>>> changed mvneta_adjust_link() so that it does not clear the auto-neg=
otiation
>>> bits in MVNETA_GMAC_AUTONEG_CONFIG register. This was necessary for
>>> auto-negotiation mode to work.
>>> Unfortunately I haven't checked if these bits are ever initialized.
>>> It appears they are not.
>>> This patch adds the missing initialization of the auto-negotiation =
bits
>>> in the MVNETA_GMAC_AUTONEG_CONFIG register.
>>> It fixes the following regression:
>>> https://www.mail-archive.com/netdev@vger.kernel.org/msg67928.html
>>>
>>> Since the patch was tested to fix a regression, it should be applie=
d to
>>> stable tree.
>>>
>>> Tested-by: Arnaud Ebalard <arno@natisbad.org>
>>>
>>> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>>> CC: Florian Fainelli <f.fainelli@gmail.com>
>>> CC: netdev@vger.kernel.org
>>> CC: linux-kernel@vger.kernel.org
>>> CC: stable@vger.kernel.org
>>>
>>> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>>> ---
>>>   drivers/net/ethernet/marvell/mvneta.c |    6 ++++++
>>>   1 file changed, 6 insertions(+)
>>>
>>> --- a/drivers/net/ethernet/marvell/mvneta.c
>>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>>> @@ -1013,6 +1013,12 @@ static void mvneta_defaults_set(struct m
>>>   		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
>>>   		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
>>>   		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
>>> +	} else {
>>> +		val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
>>> +		val &=3D ~(MVNETA_GMAC_INBAND_AN_ENABLE |
>>> +		       MVNETA_GMAC_AN_SPEED_EN |
>>> +		       MVNETA_GMAC_AN_DUPLEX_EN);
>>> +		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
>>>   	}
>>>   	mvneta_set_ucast_table(pp, -1);
>> Hi Greg.
>>
>> Another problem was reported:
>> https://lkml.org/lkml/2015/7/8/865
>>
>> So, while the above patch is correct and fixes what
>> it should, the original patch has more problems to deal
>> with. Maybe for stable it would be better to just revert
>> the whole thing?
> No, you will have to fix this in Linus's tree, right?  So I'll take t=
he
> patch that you get into there when that happens, I don't want to dive=
rge
> from what is in that tree.
=46or Linus tree I am planning a new DT property to explicitly
enable the inband status. I don't see any quick fix suitable for
-stable, and new DT property will likely not be quickly accepted.
If you don't want a revert, then the stable will likely have that
regression for quite long, that's the warning.
OTOH, the revert will remove the support for my board, so I
won't be able to even test it, which is also not perfect.
