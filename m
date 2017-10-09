From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] ravb: Add optional PHY reset during system resume
Date: Mon, 9 Oct 2017 15:50:19 +0300
Message-ID: <9bab7000-2f22-00e0-d92c-b80f3f41fab5@cogentembedded.com>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
 <1506614014-4398-3-git-send-email-geert+renesas@glider.be>
 <406f7aff-e386-31f3-39d3-17523443c265@gmail.com>
 <CAMuHMdWOAnT3xONPfU8pJi9fbAgtWL2GyRbooAxrfGDb=bsB_A@mail.gmail.com>
 <1a474c45-29ea-82fa-1ab0-0febfdc38bcb@gmail.com>
 <47456e34-2c2f-ec19-fcda-e3132a8037b3@cogentembedded.com>
 <846bb632-9fcf-3306-c2cf-4d913fd1834a@gmail.com>
 <316a7f99-d2ca-cdb2-2eca-deb044085c52@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------B11EB5B5F8042B3FD0D4AA53"
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:46766 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754231AbdJIMuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 08:50:25 -0400
Received: by mail-lf0-f54.google.com with SMTP id g70so11630540lfl.3
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 05:50:24 -0700 (PDT)
In-Reply-To: <316a7f99-d2ca-cdb2-2eca-deb044085c52@cogentembedded.com>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------B11EB5B5F8042B3FD0D4AA53
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 10/09/2017 12:37 PM, Sergei Shtylyov wrote:

>>>>>>> If the optional "reset-gpios" property is specified in DT, the generic
>>>>>>> MDIO bus code takes care of resetting the PHY during device probe.
>>>>>>> However, the PHY may still have to be reset explicitly after system
>>>>>>> resume.
>>>>>>>
>>>>>>> This allows to restore Ethernet operation after resume from s2ram on
>>>>>>> Salvator-XS, where the enable pin of the regulator providing PHY power
>>>>>>> is connected to PRESETn, and PSCI suspend powers down the SoC.
>>>>>>>
>>>>>>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>>>>>>> ---
>>>>>>>    drivers/net/ethernet/renesas/ravb_main.c | 9 +++++++++
>>>>>>>    1 file changed, 9 insertions(+)
>>>>>>>
>>>>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>>>>> index fdf30bfa403bf416..96d1d48e302f8c9a 100644
>>>>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>>> [...]
>>>>>>> @@ -2302,6 +2304,13 @@ static int __maybe_unused ravb_resume(struct
>>>>>>> device *dev)he patches
>>>>>>>          * reopen device if it was running before system suspended.
>>>>>>>          */
>>>>>>>
>>>>>>> +     /* PHY reset */
>>>>>>> +     if (bus->reset_gpiod) {
>>>>>>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 1);
>>>>>>> +             udelay(bus->reset_delay_us);
>>>>>>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 0);
>>>>>>> +     }
>>>>>>
>>>>>> This is a clever hack, but unfortunately this is also misusing the MDIO
>>>>>> bus reset line into a PHY reset line. As commented in patch 3, if this
>>>>>> reset line is tied to the PHY, then this should be a PHY property and
>>>>>
>>>>> OK.
>>>>>
>>>>>> you cannot (ab)use the MDIO bus GPIO reset logic anymore...
>>>>>
>>>>> And then I should add reset-gpios support to drivers/net/phy/micrel.c?
>>>>> Or is there already generic code to handle per-PHY reset? I couldn't
>>>>> find it.
>>>>
>>>> There is not such a thing unfortunately, but it would presumably be
>>>
>>>     It's strange you don't remember about my (abandoned) patches to
>>> handle per=PHY reset GPIOs -- perhaps it's time to unearth them. Here
>>> they are:
>>>
>>> http://patchwork.ozlabs.org/patch/616495/
>>> http://patchwork.ozlabs.org/patch/616501/
>>>
>>>     I had v3 in the works before abandoning this series -- it doesn't
>>> apply now.
>>
>> Should Geert pick-up where you left and address the feedback given in
>> v2, or do you plan to post a rebased v3?
> 
>     I was going to address the rejects in v3 and give the patchset to Geert... 
> unfortunately, this took so-o-o long. I'm going to do it today, at last.

    Here you are! Attaching both the patches against net-next.git...
Perhaps I also will be able to return to this subject in the near future...

MBR, Sergei

--------------B11EB5B5F8042B3FD0D4AA53
Content-Type: text/x-patch;
 name="phylib-add-device-reset-GPIO-support-v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="phylib-add-device-reset-GPIO-support-v3.patch"

Subject: phylib: add device reset GPIO support

The PHY devices sometimes do have their reset signal (maybe even power
supply?) tied to some GPIO and sometimes it also does happen that a boot
loader does not leave it deasserted. So far this issue has been attacked
from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
the GPIO in question; that solution, when applied to the device trees, led
to adding the PHY reset GPIO properties to the MAC device node, with one
exception: Cadence MACB driver which could handle the "reset-gpios" prop
in a PHY device subnode. I believe that the correct approach is to teach
the 'phylib' to get the MDIO device reset GPIO from the device tree node
corresponding to this device -- which this patch is doing...

Note that I had to modify the AT803x PHY driver as it would stop working
otherwise -- it made use of the reset GPIO for its own purposes...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 3:
- fixed the fwnode_get_named_gpiod() call due to the added parameters (which
  allowed to eliminate gpiod_direction_output() call);
- undeleted one blank line in the AT803x driver;
- resolved rejects, refreshed the patch;
- reworded/reformatted the changelog.

Changes in version 2:
- reformatted the changelog;
- resolved rejects, refreshed the patch.

 Documentation/devicetree/bindings/net/phy.txt |    2 +
 drivers/net/phy/at803x.c                      |   18 ++------------
 drivers/net/phy/mdio_bus.c                    |    4 +++
 drivers/net/phy/mdio_device.c                 |   27 +++++++++++++++++++--
 drivers/net/phy/phy_device.c                  |   33 ++++++++++++++++++++++++--
 drivers/of/of_mdio.c                          |   16 ++++++++++++
 include/linux/mdio.h                          |    3 ++
 include/linux/phy.h                           |    5 +++
 8 files changed, 89 insertions(+), 19 deletions(-)

Index: net-next/Documentation/devicetree/bindings/net/phy.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/phy.txt
+++ net-next/Documentation/devicetree/bindings/net/phy.txt
@@ -53,6 +53,8 @@ Optional Properties:
   to ensure the integrated PHY is used. The absence of this property indicates
   the muxers should be configured so that the external PHY is used.
 
+- reset-gpios: The GPIO phandle and specifier for the PHY reset signal.
+
 Example:
 
 ethernet-phy@0 {
Index: net-next/drivers/net/phy/at803x.c
===================================================================
--- net-next.orig/drivers/net/phy/at803x.c
+++ net-next/drivers/net/phy/at803x.c
@@ -71,7 +71,6 @@ MODULE_LICENSE("GPL");
 
 struct at803x_priv {
 	bool phy_reset:1;
-	struct gpio_desc *gpiod_reset;
 };
 
 struct at803x_context {
@@ -254,22 +253,11 @@ static int at803x_probe(struct phy_devic
 {
 	struct device *dev = &phydev->mdio.dev;
 	struct at803x_priv *priv;
-	struct gpio_desc *gpiod_reset;
 
 	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
 
-	if (phydev->drv->phy_id != ATH8030_PHY_ID)
-		goto does_not_require_reset_workaround;
-
-	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
-	if (IS_ERR(gpiod_reset))
-		return PTR_ERR(gpiod_reset);
-
-	priv->gpiod_reset = gpiod_reset;
-
-does_not_require_reset_workaround:
 	phydev->priv = priv;
 
 	return 0;
@@ -343,14 +331,14 @@ static void at803x_link_change_notify(st
 	 * cannot recover from by software.
 	 */
 	if (phydev->state == PHY_NOLINK) {
-		if (priv->gpiod_reset && !priv->phy_reset) {
+		if (phydev->mdio.reset && !priv->phy_reset) {
 			struct at803x_context context;
 
 			at803x_context_save(phydev, &context);
 
-			gpiod_set_value(priv->gpiod_reset, 1);
+			phy_device_reset(phydev, 1);
 			msleep(1);
-			gpiod_set_value(priv->gpiod_reset, 0);
+			phy_device_reset(phydev, 0);
 			msleep(1);
 
 			at803x_context_restore(phydev, &context);
Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -38,6 +38,7 @@
 #include <linux/phy.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
+#include <linux/gpio/consumer.h>
 
 #include <asm/irq.h>
 
@@ -420,6 +421,9 @@ void mdiobus_unregister(struct mii_bus *
 		if (!mdiodev)
 			continue;
 
+		if (mdiodev->reset)
+			gpiod_put(mdiodev->reset);
+
 		mdiodev->device_remove(mdiodev);
 		mdiodev->device_free(mdiodev);
 	}
Index: net-next/drivers/net/phy/mdio_device.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_device.c
+++ net-next/drivers/net/phy/mdio_device.c
@@ -12,6 +12,8 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/errno.h>
+#include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
@@ -114,6 +116,13 @@ void mdio_device_remove(struct mdio_devi
 }
 EXPORT_SYMBOL(mdio_device_remove);
 
+void mdio_device_reset(struct mdio_device *mdiodev, int value)
+{
+	if (mdiodev->reset)
+		gpiod_set_value(mdiodev->reset, value);
+}
+EXPORT_SYMBOL(mdio_device_reset);
+
 /**
  * mdio_probe - probe an MDIO device
  * @dev: device to probe
@@ -128,9 +137,16 @@ static int mdio_probe(struct device *dev
 	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
 	int err = 0;
 
-	if (mdiodrv->probe)
+	if (mdiodrv->probe) {
+		/* Deassert the reset signal */
+		mdio_device_reset(mdiodev, 0);
+
 		err = mdiodrv->probe(mdiodev);
 
+		/* Assert the reset signal */
+		mdio_device_reset(mdiodev, 1);
+	}
+
 	return err;
 }
 
@@ -140,9 +156,16 @@ static int mdio_remove(struct device *de
 	struct device_driver *drv = mdiodev->dev.driver;
 	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
 
-	if (mdiodrv->remove)
+	if (mdiodrv->remove) {
+		/* Deassert the reset signal */
+		mdio_device_reset(mdiodev, 0);
+
 		mdiodrv->remove(mdiodev);
 
+		/* Assert the reset signal */
+		mdio_device_reset(mdiodev, 1);
+	}
+
 	return 0;
 }
 
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -632,6 +632,9 @@ int phy_device_register(struct phy_devic
 	if (err)
 		return err;
 
+	/* Deassert the reset signal */
+	phy_device_reset(phydev, 0);
+
 	/* Run all of the fixups for this PHY */
 	err = phy_scan_fixups(phydev);
 	if (err) {
@@ -647,9 +650,15 @@ int phy_device_register(struct phy_devic
 		goto out;
 	}
 
+	/* Assert the reset signal */
+	phy_device_reset(phydev, 1);
+
 	return 0;
 
  out:
+	/* Assert the reset signal */
+	phy_device_reset(phydev, 1);
+
 	mdiobus_unregister_device(&phydev->mdio);
 	return err;
 }
@@ -849,6 +858,9 @@ int phy_init_hw(struct phy_device *phyde
 {
 	int ret = 0;
 
+	/* Deassert the reset signal */
+	phy_device_reset(phydev, 0);
+
 	if (!phydev->drv || !phydev->drv->config_init)
 		return 0;
 
@@ -1126,6 +1138,9 @@ void phy_detach(struct phy_device *phyde
 	put_device(&phydev->mdio.dev);
 	if (ndev_owner != bus->owner)
 		module_put(bus->owner);
+
+	/* Assert the reset signal */
+	phy_device_reset(phydev, 1);
 }
 EXPORT_SYMBOL(phy_detach);
 
@@ -1811,9 +1826,16 @@ static int phy_probe(struct device *dev)
 	/* Set the state to READY by default */
 	phydev->state = PHY_READY;
 
-	if (phydev->drv->probe)
+	if (phydev->drv->probe) {
+		/* Deassert the reset signal */
+		phy_device_reset(phydev, 0);
+
 		err = phydev->drv->probe(phydev);
 
+		/* Assert the reset signal */
+		phy_device_reset(phydev, 1);
+	}
+
 	mutex_unlock(&phydev->lock);
 
 	return err;
@@ -1829,8 +1851,15 @@ static int phy_remove(struct device *dev
 	phydev->state = PHY_DOWN;
 	mutex_unlock(&phydev->lock);
 
-	if (phydev->drv && phydev->drv->remove)
+	if (phydev->drv && phydev->drv->remove) {
+		/* Deassert the reset signal */
+		phy_device_reset(phydev, 0);
+
 		phydev->drv->remove(phydev);
+
+		/* Assert the reset signal */
+		phy_device_reset(phydev, 1);
+	}
 	phydev->drv = NULL;
 
 	return 0;
Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -47,6 +47,7 @@ static int of_get_phy_id(struct device_n
 static void of_mdiobus_register_phy(struct mii_bus *mdio,
 				    struct device_node *child, u32 addr)
 {
+	struct gpio_desc *gpiod;
 	struct phy_device *phy;
 	bool is_c45;
 	int rc;
@@ -55,10 +56,16 @@ static void of_mdiobus_register_phy(stru
 	is_c45 = of_device_is_compatible(child,
 					 "ethernet-phy-ieee802.3-c45");
 
+	/* Deassert the reset signal */
+	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
+				       GPIOD_OUT_LOW, "PHY reset");
 	if (!is_c45 && !of_get_phy_id(child, &phy_id))
 		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
 	else
 		phy = get_phy_device(mdio, addr, is_c45);
+	/* Assert the reset signal again */
+	if (!IS_ERR(gpiod))
+		gpiod_set_value(gpiod, 1);
 	if (IS_ERR(phy))
 		return;
 
@@ -78,6 +85,9 @@ static void of_mdiobus_register_phy(stru
 	of_node_get(child);
 	phy->mdio.dev.of_node = child;
 
+	if (!IS_ERR(gpiod))
+		phy->mdio.reset = gpiod;
+
 	/* All data is now stored in the phy struct;
 	 * register it */
 	rc = phy_device_register(phy);
@@ -95,6 +105,7 @@ static void of_mdiobus_register_device(s
 				       struct device_node *child, u32 addr)
 {
 	struct mdio_device *mdiodev;
+	struct gpio_desc *gpiod;
 	int rc;
 
 	mdiodev = mdio_device_create(mdio, addr);
@@ -107,6 +118,11 @@ static void of_mdiobus_register_device(s
 	of_node_get(child);
 	mdiodev->dev.of_node = child;
 
+	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
+				       GPIOD_ASIS, "PHY reset");
+	if (!IS_ERR(gpiod))
+		mdiodev->reset = gpiod;
+
 	/* All data is now stored in the mdiodev struct; register it. */
 	rc = mdio_device_register(mdiodev);
 	if (rc) {
Index: net-next/include/linux/mdio.h
===================================================================
--- net-next.orig/include/linux/mdio.h
+++ net-next/include/linux/mdio.h
@@ -12,6 +12,7 @@
 #include <uapi/linux/mdio.h>
 #include <linux/mod_devicetable.h>
 
+struct gpio_desc;
 struct mii_bus;
 
 /* Multiple levels of nesting are possible. However typically this is
@@ -39,6 +40,7 @@ struct mdio_device {
 	/* Bus address of the MDIO device (0-31) */
 	int addr;
 	int flags;
+	struct gpio_desc *reset;
 };
 #define to_mdio_device(d) container_of(d, struct mdio_device, dev)
 
@@ -71,6 +73,7 @@ void mdio_device_free(struct mdio_device
 struct mdio_device *mdio_device_create(struct mii_bus *bus, int addr);
 int mdio_device_register(struct mdio_device *mdiodev);
 void mdio_device_remove(struct mdio_device *mdiodev);
+void mdio_device_reset(struct mdio_device *mdiodev, int value);
 int mdio_driver_register(struct mdio_driver *drv);
 void mdio_driver_unregister(struct mdio_driver *drv);
 int mdio_device_bus_match(struct device *dev, struct device_driver *drv);
Index: net-next/include/linux/phy.h
===================================================================
--- net-next.orig/include/linux/phy.h
+++ net-next/include/linux/phy.h
@@ -847,6 +847,11 @@ static inline int phy_read_status(struct
 	return phydev->drv->read_status(phydev);
 }
 
+static inline void phy_device_reset(struct phy_device *phydev, int value)
+{
+	mdio_device_reset(&phydev->mdio, value);
+}
+
 #define phydev_err(_phydev, format, args...)	\
 	dev_err(&_phydev->mdio.dev, format, ##args)
 

--------------B11EB5B5F8042B3FD0D4AA53
Content-Type: text/x-patch;
 name="macb-kill-PHY-reset-code-v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="macb-kill-PHY-reset-code-v3.patch"

Subject: macb: kill PHY reset code

With  the phylib now  being aware of the "reset-gpios"  PHY node property,
there should  be no need to frob the PHY  reset in this driver anymore...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 3:
- resolved rejects due to the file being renamed, refreshed the patch;
- added the code to reset PHY on a probe error;
- edited the patch description.

 drivers/net/ethernet/cadence/macb.h      |    1 -
 drivers/net/ethernet/cadence/macb_main.c |   21 ---------------------
 2 files changed, 22 deletions(-)

Index: net-next/drivers/net/ethernet/cadence/macb.h
===================================================================
--- net-next.orig/drivers/net/ethernet/cadence/macb.h
+++ net-next/drivers/net/ethernet/cadence/macb.h
@@ -1032,7 +1032,6 @@ struct macb {
 	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
-	struct gpio_desc	*reset_gpio;
 
 	/* AT91RM9200 transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
Index: net-next/drivers/net/ethernet/cadence/macb_main.c
===================================================================
--- net-next.orig/drivers/net/ethernet/cadence/macb_main.c
+++ net-next/drivers/net/ethernet/cadence/macb_main.c
@@ -3393,7 +3393,6 @@ static int macb_probe(struct platform_de
 					      = macb_config->clk_init;
 	int (*init)(struct platform_device *) = macb_config->init;
 	struct device_node *np = pdev->dev.of_node;
-	struct device_node *phy_node;
 	struct clk *pclk, *hclk = NULL, *tx_clk = NULL, *rx_clk = NULL;
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
@@ -3499,18 +3498,6 @@ static int macb_probe(struct platform_de
 	else
 		macb_get_hwaddr(bp);
 
-	/* Power up the PHY if there is a GPIO reset */
-	phy_node =  of_get_next_available_child(np, NULL);
-	if (phy_node) {
-		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
-
-		if (gpio_is_valid(gpio)) {
-			bp->reset_gpio = gpio_to_desc(gpio);
-			gpiod_direction_output(bp->reset_gpio, 1);
-		}
-	}
-	of_node_put(phy_node);
-
 	err = of_get_phy_mode(np);
 	if (err < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -3554,10 +3541,6 @@ err_out_unregister_mdio:
 	mdiobus_unregister(bp->mii_bus);
 	mdiobus_free(bp->mii_bus);
 
-	/* Shutdown the PHY if there is a GPIO reset */
-	if (bp->reset_gpio)
-		gpiod_set_value(bp->reset_gpio, 0);
-
 err_out_free_netdev:
 	free_netdev(dev);
 
@@ -3585,10 +3568,6 @@ static int macb_remove(struct platform_d
 		dev->phydev = NULL;
 		mdiobus_free(bp->mii_bus);
 
-		/* Shutdown the PHY if there is a GPIO reset */
-		if (bp->reset_gpio)
-			gpiod_set_value(bp->reset_gpio, 0);
-
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);

--------------B11EB5B5F8042B3FD0D4AA53--
