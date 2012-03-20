From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 1/1] net: phylib: remove the length limitation of mii bus id
Date: Tue, 20 Mar 2012 16:32:12 +0800
Message-ID: <CAAQ0ZWQEoPORMXsf3xV-KPP+hOHk2euj460fORyUALnfPn3Q8g@mail.gmail.com>
References: <1332217386-3586-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332217386-3586-1-git-send-email-b29396@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20 March 2012 12:23, Dong Aisheng <b29396@freescale.com> wrote:
> From: Dong Aisheng <dong.aisheng@linaro.org>
>
> When convert to dt, the length of old mii bus id (17 bytes) is not
> sufficent to use.
> For example, the bus id could be 800f0000.ethernet-1:00 in DT.
>
> This patch removes the bus id length limitation by changing the
> bus id to a const char pionter and user could dynamically set the
> bus id via kasprintf function call.
>
> Since then no users use MII_BUS_ID_SIZE any more, just remove it.
>
> Signed-off-by: Dong Aisheng <dong.aisheng@linaro.org>
> ---
> The simplest way may just change MII_BUS_ID_SIZE to a more bigger size,
> but i'm not sure that's gonna be accepted.

The simplest fix has been applied on -next tree as below.

commit a7ed07d51c8abdb407be454c6cb6cfad613759d9
Author: Richard Zhao <richard.zhao@linaro.org>
Date:   Sun Jan 29 22:08:12 2012 +0000

    net: fec: correct phy_name buffer length when init phy_name

    Fix the bug that we got wrong phy_name on imx6q sabrelite board.
    snprintf used wrong length of phy_name.
    phy_name length is MII_BUS_ID_SIZE + 3 rather not MII_BUS_ID_SIZE.
    I change it to sizeof(phy_name).

    Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
    Acked-by: Shawn Guo <shawn.guo@linaro.org>
    Acked-by: Florian Fainelli <florian@openwrt.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/freescale/fec.c
b/drivers/net/ethernet/freescale/fec.c
index 7b25e9c..1c7aad8 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -990,7 +990,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
                phy_id = 0;
        }

-       snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
+       snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id);
        phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
                              fep->phy_interface);
        if (IS_ERR(phy_dev)) {
