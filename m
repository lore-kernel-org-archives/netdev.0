From: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 3 Apr 2013 18:23:49 +0530
Message-ID: <1364993634-6378-2-git-send-email-kishon@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, kishon-l0cyMroinI0@public.gmane.org,
 eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org,
 mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: <balbi-l0cyMroinI0@public.gmane.org>, <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
 <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
 <sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1364993634-6378-1-git-send-email-kishon-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

The PHY framework provides a set of APIs for the PHY drivers to
create/destroy a PHY and APIs for the PHY users to obtain a reference to the
PHY with or without using phandle. To obtain a reference to the PHY without
using phandle, the platform specfic intialization code (say from board file)
should have already called phy_bind with the binding information. The binding
information consists of phy's device name, phy user device name and an index.
The index is used when the same phy user binds to mulitple phys.

PHY drivers should create the PHY by passing phy_descriptor that has
describes the PHY (label, type etc..) and ops like init, exit, suspend, resume,
power_on, power_off.

The documentation for the generic PHY framework is added in
Documentation/phy.txt and the documentation for the sysfs entry is added
in Documentation/ABI/testing/sysfs-class-phy and the documentation for
dt binding is can be found at
Documentation/devicetree/bindings/phy/phy-bindings.txt

Signed-off-by: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-class-phy          |   15 +
 .../devicetree/bindings/phy/phy-bindings.txt       |   67 +++
 Documentation/phy.txt                              |  113 ++++
 MAINTAINERS                                        |    7 +
 drivers/Kconfig                                    |    2 +
 drivers/Makefile                                   |    2 +
 drivers/phy/Kconfig                                |   13 +
 drivers/phy/Makefile                               |    5 +
 drivers/phy/phy-core.c                             |  616 ++++++++++++++++++++
 include/linux/phy/phy.h                            |  228 ++++++++
 10 files changed, 1068 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-phy
 create mode 100644 Documentation/devicetree/bindings/phy/phy-bindings.txt
 create mode 100644 Documentation/phy.txt
 create mode 100644 drivers/phy/Kconfig
 create mode 100644 drivers/phy/Makefile
 create mode 100644 drivers/phy/phy-core.c
 create mode 100644 include/linux/phy/phy.h

diff --git a/Documentation/ABI/testing/sysfs-class-phy b/Documentation/ABI/testing/sysfs-class-phy
new file mode 100644
index 0000000..b735467
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-phy
@@ -0,0 +1,15 @@
+What:		/sys/class/phy/<phy>/label
+Date:		Apr 2013
+KernelVersion:	3.10
+Contact:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
+Description:
+		This is a read-only file for getting the label of the phy.
+
+What:		/sys/class/phy/<phy>/phy_bind
+Date:		Apr 2013
+KernelVersion:	3.10
+Contact:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
+Description:
+		This is a read-only file for reading the phy binding
+		information. It contains the device name of the controller,
+		the index and the device name of the PHY in that order.
diff --git a/Documentation/devicetree/bindings/phy/phy-bindings.txt b/Documentation/devicetree/bindings/phy/phy-bindings.txt
new file mode 100644
index 0000000..e7b246a
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/phy-bindings.txt
@@ -0,0 +1,67 @@
+This document explains only the dt data binding. For general information about
+PHY subsystem refer Documentation/phy.txt
+
+PHY device node
+===============
+
+Required Properties:
+#phy-cells:	Number of cells in a PHY specifier;  The meaning of all those
+		cells is defined by the binding for the phy node. The PHY
+		provider can use the values in cells to find the appropriate
+		PHY.
+
+For example:
+
+phys: phy {
+    compatible = "xxx";
+    reg = <...>;
+    .
+    .
+    #phy-cells = <1>;
+    .
+    .
+};
+
+That node describes an IP block that implements 2 different PHYs. In order to
+differentiate between these 2 PHYs, an additonal specifier should be given
+while trying to get a reference to it.
+
+PHY user node
+=============
+
+Required Properties:
+phys : the phandle for the PHY device (used by the PHY subsystem)
+
+Optional properties:
+phy-names : the names of the PHY corresponding to the PHYs present in the
+	    *phys* phandle
+
+Example 1:
+usb1: usb_otg_ss@xxx {
+    compatible = "xxx";
+    reg = <xxx>;
+    .
+    .
+    phys = <&usb2_phy>, <&usb3_phy>;
+    phy-names = "usb2phy", "usb3phy";
+    .
+    .
+};
+
+This node represents a controller that uses two PHYs one for usb2 and one for
+usb3.
+
+Example 2:
+usb2: usb_otg_ss@xxx {
+    compatible = "xxx";
+    reg = <xxx>;
+    .
+    .
+    phys = <&phys 1>;
+    .
+    .
+};
+
+This node represents a controller that uses one of the PHYs which is defined
+previously. Note that the phy handle has an additional specifier "1" to
+differentiate between the two PHYs.
diff --git a/Documentation/phy.txt b/Documentation/phy.txt
new file mode 100644
index 0000000..7785ec0
--- /dev/null
+++ b/Documentation/phy.txt
@@ -0,0 +1,113 @@
+			    PHY SUBSYSTEM
+		  Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
+
+This document explains the Generic PHY Framework along with the APIs provided,
+and how-to-use.
+
+1. Introduction
+
+*PHY* is the abbreviation for physical layer. It is used to connect a device
+to the physical medium e.g., the USB controller has a PHY to provide functions
+such as serialization, de-serialization, encoding, decoding and is responsible
+for obtaining the required data transmission rate. Note that some USB
+controller has PHY functionality embedded into it and others use an external
+PHY. Other peripherals that uses a PHY include Wireless LAN, Ethernet,
+SATA etc.
+
+The intention of creating this framework is to bring the phy drivers spread
+all over the Linux kernel to drivers/phy to increase code re-use and to
+increase code maintainability.
+
+This framework will be of use only to devices that uses external PHY (PHY
+functionality is not embedded within the controller).
+
+2. Creating the PHY
+
+The PHY driver should create the PHY in order for other peripheral controllers
+to make use of it. The PHY framework provides 2 APIs to create the PHY.
+
+struct phy *phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv);
+struct phy *devm_phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv);
+
+The PHY drivers can use one of the above 2 APIs to create the PHY by passing
+the device pointer, label, device node, type, phy ops and a driver data.
+phy_ops is a set of function pointers for performing PHY operations such as
+init, exit, suspend, resume, power_on and power_off.
+
+3. Binding the PHY to the controller
+
+The framework provides an API for binding the controller to the PHY in the
+case of non dt boot.
+
+struct phy_bind *phy_bind(const char *dev_name, int index,
+				const char *phy_dev_name);
+
+The API fills the phy_bind structure with the dev_name (device name of the
+controller), index and phy_dev_name (device name of the PHY). This will
+be used when the controller requests this phy. This API should be used by
+platform specific initialization code (board file).
+
+In the case of dt boot, the binding information should be added in the dt
+data of the controller.
+
+4. Getting a reference to the PHY
+
+Before the controller can make use of the PHY, it has to get a reference to
+it. This framework provides 6 APIs to get a reference to the PHY.
+
+struct phy *phy_get(struct device *dev, int index);
+struct phy *devm_phy_get(struct device *dev, int index);
+struct phy *of_phy_get(struct device *dev, const char *phandle, int index);
+struct phy *devm_of_phy_get(struct device *dev, const char *phandle, int index);
+struct phy *of_phy_get_byname(struct device *dev, const char *string);
+struct phy *devm_of_phy_get_byname(struct device *dev, const char *string);
+
+phy_get and devm_phy_get can be used to get the PHY in non-dt boot. This API
+uses the binding information added using the phy_bind API to find and return
+the appropriate PHY. The only difference between the two APIs is that
+devm_phy_get associates the device with the PHY using devres on successful PHY
+get. On driver detach, release function is invoked on the the devres data and
+devres data is freed.
+
+of_phy_get and devm_of_phy_get can be used to get the PHY in dt boot. These
+APIs take the phandle and index to get a reference to the PHY. The only
+difference between the two APIs is that devm_of_phy_get associates the device
+with the PHY using devres on successful phy get. On driver detach, release
+function is invoked on the devres data and it is freed.
+
+of_phy_get_byname and devm_of_phy_get_byname can also be used to get the PHY
+in dt boot. It is same as the above API except that the user has to pass the
+phy name as filled in "phy-names" phandle in dt data and the framework will
+find the index and get the PHY.
+
+5. Releasing a reference to the PHY
+
+When the controller no longer needs the PHY, it has to release the reference
+to the PHY it has obtained using the APIs mentioned in the above section. The
+PHY framework provides 2 APIS to release a reference to the PHY.
+
+void phy_put(struct phy *phy);
+void devm_phy_put(struct device *dev, struct phy *phy);
+
+Both these APIs are used to release a reference to the PHY and devm_phy_put
+destroys the devres associated with this PHY.
+
+6. Destroying the PHY
+
+When the driver that created the PHY is unloaded, it should destroy the PHY it
+created using one of the following 2 APIs.
+
+void phy_destroy(struct phy *phy);
+void devm_phy_destroy(struct device *dev, struct phy *phy);
+
+Both these APIs destroys the PHY and devm_phy_destroy destroys the devres
+associated with this PHY.
+
+7. DeviceTree Binding
+
+The documentation for PHY dt binding can be found @
+Documentation/devicetree/bindings/phy/phy-bindings.txt
diff --git a/MAINTAINERS b/MAINTAINERS
index 72b0843..f2674e7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3474,6 +3474,13 @@ S:	Maintained
 F:	include/asm-generic
 F:	include/uapi/asm-generic
 
+GENERIC PHY FRAMEWORK
+M:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
+L:	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Supported
+F:	drivers/phy/
+F:	include/linux/phy/
+
 GENERIC UIO DRIVER FOR PCI DEVICES
 M:	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 L:	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
diff --git a/drivers/Kconfig b/drivers/Kconfig
index 202fa6d..ad2c374a 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -162,4 +162,6 @@ source "drivers/irqchip/Kconfig"
 
 source "drivers/ipack/Kconfig"
 
+source "drivers/phy/Kconfig"
+
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index dce39a9..9da8321 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -45,6 +45,8 @@ obj-y				+= char/
 # gpu/ comes after char for AGP vs DRM startup
 obj-y				+= gpu/
 
+obj-y				+= phy/
+
 obj-$(CONFIG_CONNECTOR)		+= connector/
 
 # i810fb and intelfb depend on char/agp/
diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
new file mode 100644
index 0000000..5f85909
--- /dev/null
+++ b/drivers/phy/Kconfig
@@ -0,0 +1,13 @@
+#
+# PHY
+#
+
+menuconfig GENERIC_PHY
+	tristate "PHY Subsystem"
+	help
+	  Generic PHY support.
+
+	  This framework is designed to provide a generic interface for PHY
+	  devices present in the kernel. This layer will have the generic
+	  API by which phy drivers can create PHY using the phy framework and
+	  phy users can obtain reference to the PHY.
diff --git a/drivers/phy/Makefile b/drivers/phy/Makefile
new file mode 100644
index 0000000..9e9560f
--- /dev/null
+++ b/drivers/phy/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the phy drivers.
+#
+
+obj-$(CONFIG_GENERIC_PHY)	+= phy-core.o
diff --git a/drivers/phy/phy-core.c b/drivers/phy/phy-core.c
new file mode 100644
index 0000000..1d753f2
--- /dev/null
+++ b/drivers/phy/phy-core.c
@@ -0,0 +1,616 @@
+/*
+ * phy-core.c  --  Generic Phy framework.
+ *
+ * Copyright (C) 2013 Texas Instruments
+ *
+ * Author: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/device.h>
+#include <linux/slab.h>
+#include <linux/of.h>
+#include <linux/phy/phy.h>
+
+static struct class *phy_class;
+static DEFINE_MUTEX(phy_bind_mutex);
+static LIST_HEAD(phy_bind_list);
+static int phy_core_init(void);
+
+static void devm_phy_release(struct device *dev, void *res)
+{
+	struct phy *phy = *(struct phy **)res;
+
+	phy_put(phy);
+}
+
+static void devm_phy_consume(struct device *dev, void *res)
+{
+	struct phy *phy = *(struct phy **)res;
+
+	phy_destroy(phy);
+}
+
+static int devm_phy_match(struct device *dev, void *res, void *match_data)
+{
+	return res == match_data;
+}
+
+static struct phy *phy_lookup(struct device *dev, int index)
+{
+	struct phy_bind *phy_bind = NULL;
+
+	list_for_each_entry(phy_bind, &phy_bind_list, list) {
+		if (!(strcmp(phy_bind->dev_name, dev_name(dev)) &&
+				phy_bind->index == index)) {
+			if (phy_bind->phy)
+				return phy_bind->phy;
+			else
+				return ERR_PTR(-EPROBE_DEFER);
+		}
+	}
+
+	return ERR_PTR(-ENODEV);
+}
+
+static struct phy *of_phy_lookup(struct device_node *node)
+{
+	struct phy *phy;
+	struct device *dev;
+	struct class_dev_iter iter;
+
+	class_dev_iter_init(&iter, phy_class, NULL, NULL);
+	while ((dev = class_dev_iter_next(&iter))) {
+		phy = container_of(dev, struct phy, dev);
+		if (node != phy->of_node)
+			continue;
+
+		class_dev_iter_exit(&iter);
+		return phy;
+	}
+
+	class_dev_iter_exit(&iter);
+	return ERR_PTR(-EPROBE_DEFER);
+}
+
+/**
+ * phy_put() - release the PHY
+ * @phy: the phy returned by phy_get()
+ *
+ * Releases a refcount the caller received from phy_get().
+ */
+void phy_put(struct phy *phy)
+{
+	if (!IS_ERR(phy)) {
+		module_put(phy->ops->owner);
+		put_device(&phy->dev);
+	}
+}
+EXPORT_SYMBOL_GPL(phy_put);
+
+/**
+ * devm_phy_put() - release the PHY
+ * @dev: device that wants to release this phy
+ * @phy: the phy returned by devm_phy_get()
+ *
+ * destroys the devres associated with this phy and invokes phy_put
+ * to release the phy.
+ */
+void devm_phy_put(struct device *dev, struct phy *phy)
+{
+	int r;
+
+	r = devres_destroy(dev, devm_phy_release, devm_phy_match, phy);
+	dev_WARN_ONCE(dev, r, "couldn't find PHY resource\n");
+}
+EXPORT_SYMBOL_GPL(devm_phy_put);
+
+/**
+ * of_phy_xlate() - returns the phy instance from phy provider
+ * @phy: the phy returned by of_phy_lookup()
+ * @args: of_phandle_args (not used here)
+ *
+ * Intended to be used by phy provider for the common case where #phy-cells is
+ * 0. For other cases where #phy-cells is greater than '0', the phy provider
+ * should provide a custom of_xlate function that reads the *args* and returns
+ * the appropriate phy.
+ */
+struct phy *of_phy_xlate(struct phy *phy, struct of_phandle_args *args)
+{
+	return phy;
+}
+EXPORT_SYMBOL_GPL(of_phy_xlate);
+
+/**
+ * of_phy_get() - lookup and obtain a reference to a phy by phandle
+ * @dev: device that requests this phy
+ * @index: the index of the phy
+ *
+ * Returns the phy associated with the given phandle value,
+ * after getting a refcount to it or -ENODEV if there is no such phy or
+ * -EPROBE_DEFER if there is a phandle to the phy, but the device is
+ * not yet loaded.
+ */
+struct phy *of_phy_get(struct device *dev, int index)
+{
+	int ret;
+	struct phy *phy = NULL;
+	struct phy_bind *phy_map = NULL;
+	struct of_phandle_args args;
+	struct device_node *node;
+
+	if (!dev->of_node) {
+		dev_dbg(dev, "device does not have a device node entry\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	ret = of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
+		index, &args);
+	if (ret) {
+		dev_dbg(dev, "failed to get phy in %s node\n",
+			dev->of_node->full_name);
+		return ERR_PTR(-ENODEV);
+	}
+
+	phy = of_phy_lookup(args.np);
+	if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
+		phy = ERR_PTR(-EPROBE_DEFER);
+		goto err0;
+	}
+
+	phy = phy->ops->of_xlate(phy, &args);
+	if (IS_ERR(phy))
+		goto err1;
+
+	phy_map = phy_bind(dev_name(dev), index, dev_name(&phy->dev));
+	if (!IS_ERR(phy_map)) {
+		phy_map->phy = phy;
+		phy_map->auto_bind = true;
+	}
+
+	get_device(&phy->dev);
+
+err1:
+	module_put(phy->ops->owner);
+
+err0:
+	of_node_put(node);
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(of_phy_get);
+
+/**
+ * devm_of_phy_get() - lookup and obtain a reference to a phy by phandle
+ * @dev: device that requests this phy
+ * @index: the index of the phy
+ *
+ * Calls of_phy_get to get a reference to the PHY and passes on the return
+ * value of of_phy_get. While at that, it also associates the device with the
+ * phy using devres on successful phy get. On driver detach, release function
+ * is invoked on the the devres data and devres data is freed.
+ */
+struct phy *devm_of_phy_get(struct device *dev, int index)
+{
+	struct phy *phy = NULL, **ptr;
+
+	ptr = devres_alloc(devm_phy_release, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	phy = of_phy_get(dev, index);
+	if (!IS_ERR(phy)) {
+		*ptr = phy;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(devm_of_phy_get);
+
+/**
+ * of_phy_get_byname() - lookup and obtain a reference to a phy by name
+ * @dev: device that requests this phy
+ * @string - the phy name as given in the dt data
+ *
+ * Calls of_phy_get to get a reference to the PHY and passes on the return
+ * value of of_phy_get.
+ */
+struct phy *of_phy_get_byname(struct device *dev, const char *string)
+{
+	int index;
+
+	if (!dev->of_node) {
+		dev_dbg(dev, "device does not have a device node entry\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	index = of_property_match_string(dev->of_node, "phy-names", string);
+
+	return of_phy_get(dev, index);
+}
+EXPORT_SYMBOL_GPL(of_phy_get_byname);
+
+/**
+ * devm_of_phy_get_byname() - lookup and obtain a reference to a phy by name
+ * @dev: device that requests this phy
+ * @string: the phy name as given in the dt data
+ *
+ * Calls devm_of_phy_get (which associates the device with the phy using devres
+ * on successful phy get) and passes on the return value of devm_of_phy_get.
+ */
+struct phy *devm_of_phy_get_byname(struct device *dev, const char *string)
+{
+	int index;
+
+	if (!dev->of_node) {
+		dev_dbg(dev, "device does not have a device node entry\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	index = of_property_match_string(dev->of_node, "phy-names", string);
+
+	return devm_of_phy_get(dev, index);
+}
+EXPORT_SYMBOL_GPL(devm_of_phy_get_byname);
+
+/**
+ * phy_get() - lookup and obtain a reference to a phy.
+ * @dev: device that requests this phy
+ * @index: the index of the phy
+ *
+ * Returns the phy driver, after getting a refcount to it; or
+ * -ENODEV if there is no such phy.  The caller is responsible for
+ * calling phy_put() to release that count.
+ */
+struct phy *phy_get(struct device *dev, int index)
+{
+	struct phy *phy = NULL;
+
+	phy = phy_lookup(dev, index);
+	if (IS_ERR(phy)) {
+		dev_err(dev, "unable to find phy\n");
+		return phy;
+	}
+
+	if (!try_module_get(phy->ops->owner))
+		return ERR_PTR(-EPROBE_DEFER);
+
+	get_device(&phy->dev);
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(phy_get);
+
+/**
+ * devm_phy_get() - lookup and obtain a reference to a phy.
+ * @dev: device that requests this phy
+ * @index: the index of the phy
+ *
+ * Gets the phy using phy_get(), and associates a device with it using
+ * devres. On driver detach, release function is invoked on the devres data,
+ * then, devres data is freed.
+ */
+struct phy *devm_phy_get(struct device *dev, int index)
+{
+	struct phy **ptr, *phy;
+
+	ptr = devres_alloc(devm_phy_release, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	phy = phy_get(dev, index);
+	if (!IS_ERR(phy)) {
+		*ptr = phy;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(devm_phy_get);
+
+/**
+ * phy_create() - create a new phy
+ * @dev: device that is creating the new phy
+ * @label: label given to phy
+ * @of_node: device node of the phy
+ * @type: specifies the phy type
+ * @ops: function pointers for performing phy operations
+ * @priv: private data from phy driver
+ *
+ * Called to create a phy using phy framework.
+ */
+struct phy *phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv)
+{
+	int ret;
+	struct phy *phy;
+	struct phy_bind *phy_bind;
+	const char *devname = NULL;
+
+	if (!dev) {
+		dev_err(dev, "no device provided for PHY\n");
+		ret = -EINVAL;
+		goto err0;
+	}
+
+	if (!ops || !ops->of_xlate || !priv) {
+		dev_err(dev, "no PHY ops/PHY data provided\n");
+		ret = -EINVAL;
+		goto err0;
+	}
+
+	if (!phy_class)
+		phy_core_init();
+
+	phy = kzalloc(sizeof(*phy), GFP_KERNEL);
+	if (!phy) {
+		ret = -ENOMEM;
+		goto err0;
+	}
+
+	devname = dev_name(dev);
+	device_initialize(&phy->dev);
+
+	phy->dev.class = phy_class;
+	phy->dev.parent = dev;
+	phy->label = label;
+	phy->of_node = of_node;
+	phy->type = type;
+	phy->ops = ops;
+
+	dev_set_drvdata(&phy->dev, priv);
+
+	ret = dev_set_name(&phy->dev, "%s", devname);
+	if (ret)
+		goto err1;
+
+	mutex_lock(&phy_bind_mutex);
+	list_for_each_entry(phy_bind, &phy_bind_list, list)
+		if (!(strcmp(phy_bind->phy_dev_name, devname)))
+			phy_bind->phy = phy;
+	mutex_unlock(&phy_bind_mutex);
+
+	ret = device_add(&phy->dev);
+	if (ret)
+		goto err2;
+
+	return phy;
+
+err2:
+	phy_bind->phy = NULL;
+
+err1:
+	put_device(&phy->dev);
+	kfree(phy);
+
+err0:
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(phy_create);
+
+/**
+ * devm_phy_create() - create a new phy
+ * @dev: device that is creating the new phy
+ * @dev: device that is creating the new phy
+ * @label: label given to phy
+ * @of_node: device node of the phy
+ * @type: specifies the phy type
+ * @ops: function pointers for performing phy operations
+ * @priv: private data from phy driver
+ *
+ * Creates a new PHY device adding it to the PHY class.
+ * While at that, it also associates the device with the phy using devres.
+ * On driver detach, release function is invoked on the devres data,
+ * then, devres data is freed.
+ */
+struct phy *devm_phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv)
+{
+	struct phy **ptr, *phy;
+
+	ptr = devres_alloc(devm_phy_consume, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	phy = phy_create(dev, label, of_node, type, ops, priv);
+	if (!IS_ERR(phy)) {
+		*ptr = phy;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(devm_phy_create);
+
+/**
+ * phy_destroy() - destroy the phy
+ * @phy: the phy to be destroyed
+ *
+ * Called to destroy the phy.
+ */
+void phy_destroy(struct phy *phy)
+{
+	struct phy_bind *phy_bind;
+
+	mutex_lock(&phy_bind_mutex);
+	list_for_each_entry(phy_bind, &phy_bind_list, list) {
+		if (phy_bind->phy == phy)
+			phy_bind->phy = NULL;
+
+		if (phy_bind->auto_bind) {
+			list_del(&phy_bind->list);
+			kfree(phy_bind);
+		}
+	}
+	mutex_unlock(&phy_bind_mutex);
+
+	device_unregister(&phy->dev);
+}
+EXPORT_SYMBOL_GPL(phy_destroy);
+
+/**
+ * devm_phy_destroy() - destroy the PHY
+ * @dev: device that wants to release this phy
+ * @phy: the phy returned by devm_phy_get()
+ *
+ * destroys the devres associated with this phy and invokes phy_destroy
+ * to destroy the phy.
+ */
+void devm_phy_destroy(struct device *dev, struct phy *phy)
+{
+	int r;
+
+	r = devres_destroy(dev, devm_phy_consume, devm_phy_match, phy);
+	dev_WARN_ONCE(dev, r, "couldn't find PHY resource\n");
+}
+EXPORT_SYMBOL_GPL(devm_phy_destroy);
+
+/**
+ * phy_bind() - bind the phy and the controller that uses the phy
+ * @dev_name: the device name of the device that will bind to the phy
+ * @index: index to specify the port number
+ * @phy_dev_name: the device name of the phy
+ *
+ * Fills the phy_bind structure with the dev_name and phy_dev_name. This will
+ * be used when the phy driver registers the phy and when the controller
+ * requests this phy.
+ *
+ * To be used by platform specific initialization code.
+ */
+struct phy_bind *phy_bind(const char *dev_name, int index,
+				const char *phy_dev_name)
+{
+	struct phy_bind *phy_bind;
+
+	mutex_lock(&phy_bind_mutex);
+	list_for_each_entry(phy_bind, &phy_bind_list, list) {
+		if (!strcmp(phy_bind->dev_name, dev_name) && phy_bind->index ==
+			index) {
+			phy_bind->phy_dev_name = phy_dev_name;
+			goto ret0;
+		}
+	}
+
+	phy_bind = kzalloc(sizeof(*phy_bind), GFP_KERNEL);
+	if (!phy_bind) {
+		phy_bind = ERR_PTR(-ENOMEM);
+		goto ret0;
+	}
+
+	phy_bind->dev_name = dev_name;
+	phy_bind->phy_dev_name = phy_dev_name;
+	phy_bind->index = index;
+	phy_bind->auto_bind = false;
+
+	list_add_tail(&phy_bind->list, &phy_bind_list);
+
+ret0:
+	mutex_unlock(&phy_bind_mutex);
+	return phy_bind;
+}
+EXPORT_SYMBOL_GPL(phy_bind);
+
+static ssize_t phy_name_show(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct phy *phy;
+
+	phy = container_of(dev, struct phy, dev);
+
+	return sprintf(buf, "%s\n", phy->label);
+}
+
+static ssize_t phy_bind_show(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct phy_bind *phy_bind;
+	struct phy *phy;
+	char *p = buf;
+	int len;
+
+	phy = container_of(dev, struct phy, dev);
+
+	list_for_each_entry(phy_bind, &phy_bind_list, list)
+		if (phy_bind->phy == phy)
+			p += sprintf(p, "%s %d %s\n", phy_bind->dev_name,
+				phy_bind->index, phy_bind->phy_dev_name);
+	len = (p - buf);
+
+	return len;
+}
+
+static struct device_attribute phy_dev_attrs[] = {
+	__ATTR(label, 0444, phy_name_show, NULL),
+	__ATTR(phy_bind, 0444, phy_bind_show, NULL),
+	__ATTR_NULL,
+};
+
+/**
+ * phy_release() - release the phy
+ * @dev: the dev member within phy
+ *
+ * when the last reference to the device is removed; it is called
+ * from the embedded kobject as release method.
+ */
+static void phy_release(struct device *dev)
+{
+	struct phy *phy;
+
+	phy = container_of(dev, struct phy, dev);
+	dev_dbg(dev, "releasing '%s'\n", dev_name(dev));
+	kfree(phy);
+}
+
+static int phy_core_init(void)
+{
+	if (phy_class)
+		return 0;
+
+	phy_class = class_create(THIS_MODULE, "phy");
+	if (IS_ERR(phy_class)) {
+		pr_err("failed to create phy class --> %ld\n",
+			PTR_ERR(phy_class));
+		return PTR_ERR(phy_class);
+	}
+
+	phy_class->dev_release = phy_release;
+	phy_class->dev_attrs = phy_dev_attrs;
+
+	return 0;
+}
+module_init(phy_core_init);
+
+static void __exit phy_core_exit(void)
+{
+	class_destroy(phy_class);
+}
+module_exit(phy_core_exit);
+
+MODULE_DESCRIPTION("Generic PHY Framework");
+MODULE_AUTHOR("Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>");
+MODULE_LICENSE("GPL v2");
diff --git a/include/linux/phy/phy.h b/include/linux/phy/phy.h
new file mode 100644
index 0000000..97a48bd
--- /dev/null
+++ b/include/linux/phy/phy.h
@@ -0,0 +1,228 @@
+/*
+ * phy.h -- generic phy header file
+ *
+ * Copyright (C) 2013 Texas Instruments Incorporated - http://www.ti.com
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * Author: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#ifndef __DRIVERS_PHY_H
+#define __DRIVERS_PHY_H
+
+#include <linux/err.h>
+#include <linux/of.h>
+#include <linux/device.h>
+
+struct phy;
+
+/**
+ * struct phy_ops - set of function pointers for performing phy operations
+ * @init: operation to be performed for initializing phy
+ * @exit: operation to be performed while exiting
+ * @suspend: suspending the phy
+ * @resume: resuming the phy
+ * @power_on: powering on the phy
+ * @power_off: powering off the phy
+ * @of_xlate: function pointer to obtain phy instance from phy pointer
+ * @owner: the module owner containing the ops
+ */
+struct phy_ops {
+	int	(*init)(struct phy *phy);
+	int	(*exit)(struct phy *phy);
+	int	(*suspend)(struct phy *phy);
+	int	(*resume)(struct phy *phy);
+	int	(*power_on)(struct phy *phy);
+	int	(*power_off)(struct phy *phy);
+	struct phy * (*of_xlate)(struct phy *phy, struct of_phandle_args *args);
+	struct module *owner;
+};
+
+/**
+ * struct phy - represent the phy device
+ * @dev: phy device
+ * @label: label given to phy
+ * @type: specifies the phy type
+ * @of_node: device node of the phy
+ * @ops: function pointers for performing phy operations
+ */
+struct phy {
+	struct device		dev;
+	const char		*label;
+	int			type;
+	struct device_node	*of_node;
+	struct phy_ops		*ops;
+};
+
+/**
+ * struct phy_bind - represent the binding for the phy
+ * @dev_name: the device name of the device that will bind to the phy
+ * @phy_dev_name: the device name of the phy
+ * @index: used if a single controller uses multiple phys
+ * @auto_bind: tells if the binding is done explicitly from board file or not
+ * @phy: reference to the phy
+ * @list: to maintain a linked list of the binding information
+ */
+struct phy_bind {
+	const char	*dev_name;
+	const char	*phy_dev_name;
+	int		index;
+	int		auto_bind:1;
+	struct phy	*phy;
+	struct list_head list;
+};
+
+#if IS_ENABLED(CONFIG_GENERIC_PHY)
+extern struct phy *phy_get(struct device *dev, int index);
+extern struct phy *devm_phy_get(struct device *dev, int index);
+extern struct phy *of_phy_get(struct device *dev, int index);
+extern struct phy *devm_of_phy_get(struct device *dev, int index);
+extern struct phy *of_phy_get_byname(struct device *dev, const char *string);
+extern struct phy *devm_of_phy_get_byname(struct device *dev,
+	const char *string);
+extern void phy_put(struct phy *phy);
+extern void devm_phy_put(struct device *dev, struct phy *phy);
+extern struct phy *of_phy_xlate(struct phy *phy, struct of_phandle_args *args);
+extern struct phy *phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv);
+extern struct phy *devm_phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv);
+extern void phy_destroy(struct phy *phy);
+extern void devm_phy_destroy(struct device *dev, struct phy *phy);
+extern struct phy_bind *phy_bind(const char *dev_name, int index,
+				const char *phy_dev_name);
+#else
+static inline struct phy *phy_get(struct device *dev, int index)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *devm_phy_get(struct device *dev, int index)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *of_phy_get(struct device *dev, int index)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *devm_of_phy_get(struct device *dev, int index)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *of_phy_get_byname(struct device *dev,
+	const char *string)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *devm_of_phy_get_byname(struct device *dev,
+	const char *string)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline void phy_put(struct phy *phy)
+{
+}
+
+static inline void devm_phy_put(struct device *dev, struct phy *phy)
+{
+}
+
+static inline struct phy *of_phy_xlate(struct phy *phy,
+	struct of_phandle_args *args)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct phy *devm_phy_create(struct device *dev, const char *label,
+	struct device_node *of_node, int type, struct phy_ops *ops,
+	void *priv)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline void phy_destroy(struct phy *phy)
+{
+}
+
+static inline void devm_phy_destroy(struct device *dev, struct phy *phy)
+{
+}
+
+static inline struct phy_bind *phy_bind(const char *dev_name, int index,
+				const char *phy_dev_name)
+{
+	return ERR_PTR(-ENOSYS);
+}
+#endif
+
+static inline int phy_init(struct phy *phy)
+{
+	if (phy->ops->init)
+		return phy->ops->init(phy);
+
+	return -EINVAL;
+}
+
+static inline int phy_exit(struct phy *phy)
+{
+	if (phy->ops->exit)
+		return phy->ops->exit(phy);
+
+	return -EINVAL;
+}
+
+static inline int phy_suspend(struct phy *phy)
+{
+	if (phy->ops->suspend)
+		return phy->ops->suspend(phy);
+
+	return -EINVAL;
+}
+
+static inline int phy_resume(struct phy *phy)
+{
+	if (phy->ops->resume)
+		return phy->ops->resume(phy);
+
+	return -EINVAL;
+}
+
+static inline int phy_poweron(struct phy *phy)
+{
+	if (phy->ops->power_on)
+		return phy->ops->power_on(phy);
+
+	return -EINVAL;
+}
+
+static inline int phy_poweroff(struct phy *phy)
+{
+	if (phy->ops->power_off)
+		return phy->ops->power_off(phy);
+
+	return -EINVAL;
+}
+#endif /* __DRIVERS_PHY_H */
-- 
1.7.10.4
