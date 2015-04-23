From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: refactor RTL8211F initialization
Date: Wed, 22 Apr 2015 21:39:29 -0700
Message-ID: <55387781.3010707@gmail.com>
References: <1429698120-17882-1-git-send-email-Shengzhou.Liu@freescale.com> <5537D2F0.9050903@gmail.com> <DM2PR03MB398CDA834F4E9BAFE2AF34CF8ED0@DM2PR03MB398.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Shengzhou.Liu@freescale.com" <Shengzhou.Liu@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"joe.hershberger@gmail.com" <joe.hershberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35648 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbbDWEjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 00:39:31 -0400
Received: by obcux3 with SMTP id ux3so5180940obc.2
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 21:39:31 -0700 (PDT)
In-Reply-To: <DM2PR03MB398CDA834F4E9BAFE2AF34CF8ED0@DM2PR03MB398.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/04/2015 20:53, Shengzhou.Liu@freescale.com a =C3=A9crit :
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Thursday, April 23, 2015 12:57 AM
>> To: Liu Shengzhou-B36685; netdev@vger.kernel.org; joe.hershberger@gm=
ail.com
>> Subject: Re: [PATCH] net/phy: refactor RTL8211F initialization
>>
>> On 22/04/15 03:22, Shengzhou Liu wrote:
>>> RTL8211F needs to enalbe TXDLY for RGMII during phy initialization,=
 so
>>> move it to rtl8211f_config for early initialization.
>>>
>>> Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
>>> cc: Joe Hershberger <joe.hershberger@gmail.com>
>>> ---
>>>  drivers/net/phy/realtek.c | 25 +++++++++++++++++--------
>>>  1 file changed, 17 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
>>> index 3917c82..d48095b 100644
>>> --- a/drivers/net/phy/realtek.c
>>> +++ b/drivers/net/phy/realtek.c
>>> @@ -43,6 +43,22 @@ static int rtl8211x_config(struct phy_device *ph=
ydev)
>>>  	return 0;
>>>  }
>>>
>>> +static int rtl8211f_config(struct phy_device *phydev) {
>>> +	phy_write(phydev, MDIO_DEVAD_NONE, MII_BMCR, BMCR_RESET);
>>
>> That part of the change is not documented but has to be, and you sho=
uld use
>> genphy_soft_reset() which also takes care of waiting the required am=
ount of
>> time before BMCR_RESET is cleared.
>=20
> There is no genphy_soft_reset() in current u-boot tree.=20

Did you mean to submit that against u-boot or Linux? If the latter,
there is absolutely no need to have the same file compile under u-boot
and Linux without changes, that is too restrictive. There is a
genphy_soft_reset() which takes care of waiting for BMCR_RESET to clear=
,
please use it, there is no guarantee otherwise that a PHY has completed
a reset.
--
=46lorian
