From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 2/2] net: stmmac: add fixed_phy and phy_addr support using
 DT file
Date: Fri, 23 Jan 2015 12:57:24 +0800
Message-ID: <CACVXFVPDjArXCoghEsp9g9UjDLqUaB06kT_skN7Vwy43JfXaaA@mail.gmail.com>
References: <1421980893-14475-1-git-send-email-ming.lei@canonical.com>
	<1421980893-14475-3-git-send-email-ming.lei@canonical.com>
	<54C1CADD.4060103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org,
	Byungho An <bh74.an@samsung.com>, Kukjin Kim <kgene@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <54C1CADD.4060103@gmail.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 23, 2015 at 12:15 PM, Florian Fainelli <f.fainelli@gmail.co=
m> wrote:
> Le 22/01/2015 18:41, Ming Lei a =C3=A9crit :
>> From: Byungho An <bh74.an@samsung.com>
>>
>> This patch adds codes for DT file support, fixed_phy and phy_addr
>> can be set in DT file.
>>
>> Signed-off-by: Byungho An <bh74.an@samsung.com> (bypass check for
>> fixed phy) Signed-off-by: Ming Lei<ming.lei@canonical.com> ---
>> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    5 ++++-
>> .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    7 +++++++ 2
>> files changed, 11 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c index
>> 8c6b7c16..ddb4351 100644 ---
>> a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c +++
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c @@ -847,8
>> +847,11 @@ static int stmmac_init_phy(struct net_device *dev) * 0
>> rather than 0xffff. Catch this here and treat 0 as a non-existent *
>> device as well. * Note: phydev->phy_id is the result of reading the
>> UID PHY registers. +   * But phy_id returned from fixed phy is
>> always zero, so bypass the +   * check for fixed phy. */ -    if
>> (phydev->phy_id =3D=3D 0) { +     if (phydev->phy_id =3D=3D 0 &&
>> (!priv->plat->phy_bus_name || +
>> strcmp(priv->plat->phy_bus_name,"fixed"))) {
>> phy_disconnect(phydev); return -ENODEV; } diff --git
>> a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c index
>> 879e29f..4f11491 100644 ---
>> a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c +++
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c @@ -128,6
>> +128,7 @@ static int stmmac_probe_config_dt(struct platform_device
>> *pdev, struct device_node *np =3D pdev->dev.of_node; struct
>> stmmac_dma_cfg *dma_cfg; const struct of_device_id *device; + u32
>> phy_addr;
>>
>> if (!np) return -ENODEV; @@ -217,6 +218,12 @@ static int
>> stmmac_probe_config_dt(struct platform_device *pdev, plat->pmt =3D
>> 1; }
>>
>> +     if (of_find_property(np, "fixed_phy", NULL)) { +
>> plat->phy_bus_name =3D "fixed"; +               of_property_read_u32=
(np,
>> "phy_addr", &phy_addr); +             plat->phy_addr =3D phy_addr; +=
    }
>
> Humm, same here, it would look like you could use the existing Device
> Tree helpers for parsing and registering a fixed PHY here, provided
> that you use the proper binding though.

OK, I will try to use the existing DT helpers in v1.

>
> BTW, Ming Lei's email is bouncing, do we have an updated email he
> could be contacted with?

Sorry, my signed-off-by email in the 1st patch is wrong(typo), and
the address in this email and patch is correct.

Thanks,
Ming Lei
