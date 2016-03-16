From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH (net-next.git) 2/2] stmmac: fix MDIO settings
Date: Wed, 16 Mar 2016 12:03:14 +0100
Message-ID: <56E93D72.7060106@suse.de>
References: <1458121942-5537-1-git-send-email-peppe.cavallaro@st.com>
 <1458121942-5537-3-git-send-email-peppe.cavallaro@st.com>
 <CAG374jDJS7TUSx0Ob38x4aRYHyrA+OWeCDm+f-Ytq8YZhwkEqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fschaefer.oss@googlemail.com,
	Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Phil Reid <preid@electromag.com.au>
To: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50691 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966651AbcCPLDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 07:03:19 -0400
In-Reply-To: <CAG374jDJS7TUSx0Ob38x4aRYHyrA+OWeCDm+f-Ytq8YZhwkEqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.03.2016 um 12:01 schrieb Gabriel Fernandez:
> Hi Pepe,
>=20
> i have a kernel crash
>=20
> [    2.714097] Unable to handle kernel NULL pointer dereference at
> virtual address 000001d6
> [    2.722188] pgd =3D c0204000
> [    2.724886] [000001d6] *pgd=3D00000000
> [    2.728452] Internal error: Oops: 5 [#1] SMP ARM
> [    2.733054] Modules linked in:
> [    2.736095] CPU: 1 PID: 1 Comm: swapper/0 Not tainted
> 4.5.0-rc7-01768-g3407893 #36
> [    2.743649] Hardware name: STiH415/416 SoC with Flattened Device T=
ree
> [    2.750074] task: ee070000 ti: ee05e000 task.ti: ee05e000
> [    2.755467] PC is at stmmac_open+0xcc/0xc40
> [    2.759641] LR is at of_phy_connect+0x44/0x5c
>=20
>=20
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 4c5ce98..943500b 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -278,7 +278,6 @@ static void stmmac_eee_ctrl_timer(unsigned long =
arg)
>>   */
>>  bool stmmac_eee_init(struct stmmac_priv *priv)
>>  {
>> -       char *phy_bus_name =3D priv->plat->phy_bus_name;
>>         unsigned long flags;
>>         bool ret =3D false;
>>
>> @@ -290,7 +289,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>>                 goto out;
>>
>>         /* Never init EEE in case of a switch is attached */
>> -       if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
>> +       if (priv->phydev->is_pseudo_fixed_link)
>=20
> priv->phydev is not yet affected
> replace by if (phydev->is_pseudo_fixed_link) instead ?

Indeed that's how I had it in my own patch before. Thanks for spotting.

Regards,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg, Germany
GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG=
 N=C3=BCrnberg)
