From: Dong Aisheng <dongas86@gmail.com>
Subject: Re: [PATCH 1/1] net: phylib: remove the length limitation of mii bus id
Date: Tue, 20 Mar 2012 03:53:19 -0700
Message-ID: <CAA+hA=Ttc9RDmK1fDPCtqLpf91DYDDFSf3E6zWQ6seyw7sNqTg@mail.gmail.com>
References: <1332217386-3586-1-git-send-email-b29396@freescale.com>
	<CAAQ0ZWQEoPORMXsf3xV-KPP+hOHk2euj460fORyUALnfPn3Q8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dong Aisheng <b29396@freescale.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAQ0ZWQEoPORMXsf3xV-KPP+hOHk2euj460fORyUALnfPn3Q8g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2012 at 1:32 AM, Shawn Guo <shawn.guo@linaro.org> wrote=
:
> On 20 March 2012 12:23, Dong Aisheng <b29396@freescale.com> wrote:
>> From: Dong Aisheng <dong.aisheng@linaro.org>
>>
>> When convert to dt, the length of old mii bus id (17 bytes) is not
>> sufficent to use.
>> For example, the bus id could be 800f0000.ethernet-1:00 in DT.
>>
>> This patch removes the bus id length limitation by changing the
>> bus id to a const char pionter and user could dynamically set the
>> bus id via kasprintf function call.
>>
>> Since then no users use MII_BUS_ID_SIZE any more, just remove it.
>>
>> Signed-off-by: Dong Aisheng <dong.aisheng@linaro.org>
>> ---
>> The simplest way may just change MII_BUS_ID_SIZE to a more bigger si=
ze,
>> but i'm not sure that's gonna be accepted.
>
> The simplest fix has been applied on -next tree as below.
>
Oh, i missed it, seems my patch covers that change.
But that patch only fixed wrong phy_name buffer length issue.
My patch is totally remove the length limitation of bus id and phy_name
or the bus id name will be truncated if it's longer than MII_BUS_ID_SIZ=
E
which is not a comfortable limitation.

> commit a7ed07d51c8abdb407be454c6cb6cfad613759d9
> Author: Richard Zhao <richard.zhao@linaro.org>
> Date: =A0 Sun Jan 29 22:08:12 2012 +0000
>
> =A0 =A0net: fec: correct phy_name buffer length when init phy_name
>
> =A0 =A0Fix the bug that we got wrong phy_name on imx6q sabrelite boar=
d.
> =A0 =A0snprintf used wrong length of phy_name.
> =A0 =A0phy_name length is MII_BUS_ID_SIZE + 3 rather not MII_BUS_ID_S=
IZE.
> =A0 =A0I change it to sizeof(phy_name).
>
> =A0 =A0Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> =A0 =A0Acked-by: Shawn Guo <shawn.guo@linaro.org>
> =A0 =A0Acked-by: Florian Fainelli <florian@openwrt.org>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/ethernet/freescale/fec.c
> b/drivers/net/ethernet/freescale/fec.c
> index 7b25e9c..1c7aad8 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -990,7 +990,7 @@ static int fec_enet_mii_probe(struct net_device *=
ndev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_id =3D 0;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bu=
s_id, phy_id);
> + =A0 =A0 =A0 snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_b=
us_id, phy_id);
> =A0 =A0 =A0 =A0phy_dev =3D phy_connect(ndev, phy_name, &fec_enet_adju=
st_link, 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->phy_i=
nterface);
> =A0 =A0 =A0 =A0if (IS_ERR(phy_dev)) {
