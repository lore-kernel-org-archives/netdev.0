From: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 3 Apr 2013 19:48:42 +0530
Message-ID: <515C3A42.4020404@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-2-git-send-email-kishon@ti.com>
 <20130403134102.GC14680@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org, cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org,
 eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20130403134102.GC14680-S8G//mZuvNWo5Im9Ml3/Zg@public.gmane.org>
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

Hi,

On Wednesday 03 April 2013 07:12 PM, Felipe Balbi wrote:
> On Wed, Apr 03, 2013 at 06:23:49PM +0530, Kishon Vijay Abraham I wrote:
>> The PHY framework provides a set of APIs for the PHY drivers to
>> create/destroy a PHY and APIs for the PHY users to obtain a reference to the
>> PHY with or without using phandle. To obtain a reference to the PHY without
>> using phandle, the platform specfic intialization code (say from board file)
>> should have already called phy_bind with the binding information. The binding
>> information consists of phy's device name, phy user device name and an index.
>> The index is used when the same phy user binds to mulitple phys.
>>
>> PHY drivers should create the PHY by passing phy_descriptor that has
>> describes the PHY (label, type etc..) and ops like init, exit, suspend, resume,
>> power_on, power_off.
>>
>> The documentation for the generic PHY framework is added in
>> Documentation/phy.txt and the documentation for the sysfs entry is added
>> in Documentation/ABI/testing/sysfs-class-phy and the documentation for
>> dt binding is can be found at
>> Documentation/devicetree/bindings/phy/phy-bindings.txt
>>
>> Signed-off-by: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
>> ---
>>   Documentation/ABI/testing/sysfs-class-phy          |   15 +
>>   .../devicetree/bindings/phy/phy-bindings.txt       |   67 +++
>>   Documentation/phy.txt                              |  113 ++++
>>   MAINTAINERS                                        |    7 +
>>   drivers/Kconfig                                    |    2 +
>>   drivers/Makefile                                   |    2 +
>>   drivers/phy/Kconfig                                |   13 +
>>   drivers/phy/Makefile                               |    5 +
>>   drivers/phy/phy-core.c                             |  616 ++++++++++++++++++++
>>   include/linux/phy/phy.h                            |  228 ++++++++
>>   10 files changed, 1068 insertions(+)
>>   create mode 100644 Documentation/ABI/testing/sysfs-class-phy
>>   create mode 100644 Documentation/devicetree/bindings/phy/phy-bindings.txt
>>   create mode 100644 Documentation/phy.txt
>>   create mode 100644 drivers/phy/Kconfig
>>   create mode 100644 drivers/phy/Makefile
>>   create mode 100644 drivers/phy/phy-core.c
>>   create mode 100644 include/linux/phy/phy.h
>>
>> diff --git a/Documentation/ABI/testing/sysfs-class-phy b/Documentation/ABI/testing/sysfs-class-phy
>> new file mode 100644
>> index 0000000..b735467
>> --- /dev/null
>> +++ b/Documentation/ABI/testing/sysfs-class-phy
>> @@ -0,0 +1,15 @@
>> +What:		/sys/class/phy/<phy>/label
>> +Date:		Apr 2013
>> +KernelVersion:	3.10
>> +Contact:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
>> +Description:
>> +		This is a read-only file for getting the label of the phy.
>> +
>> +What:		/sys/class/phy/<phy>/phy_bind
>> +Date:		Apr 2013
>> +KernelVersion:	3.10
>> +Contact:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
>> +Description:
>> +		This is a read-only file for reading the phy binding
>> +		information. It contains the device name of the controller,
>> +		the index and the device name of the PHY in that order.
>> diff --git a/Documentation/devicetree/bindings/phy/phy-bindings.txt b/Documentation/devicetree/bindings/phy/phy-bindings.txt
>> new file mode 100644
>> index 0000000..e7b246a
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/phy/phy-bindings.txt
>> @@ -0,0 +1,67 @@
>> +This document explains only the dt data binding. For general information about
>> +PHY subsystem refer Documentation/phy.txt
>> +
>> +PHY device node
>> +===============
>> +
>> +Required Properties:
>> +#phy-cells:	Number of cells in a PHY specifier;  The meaning of all those
>> +		cells is defined by the binding for the phy node. The PHY
>> +		provider can use the values in cells to find the appropriate
>> +		PHY.
>> +
>> +For example:
>> +
>> +phys: phy {
>> +    compatible = "xxx";
>> +    reg = <...>;
>> +    .
>> +    .
>> +    #phy-cells = <1>;
>> +    .
>> +    .
>> +};
>> +
>> +That node describes an IP block that implements 2 different PHYs. In order to
>> +differentiate between these 2 PHYs, an additonal specifier should be given
>> +while trying to get a reference to it.
>> +
>> +PHY user node
>> +=============
>> +
>> +Required Properties:
>> +phys : the phandle for the PHY device (used by the PHY subsystem)
>> +
>> +Optional properties:
>> +phy-names : the names of the PHY corresponding to the PHYs present in the
>> +	    *phys* phandle
>> +
>> +Example 1:
>> +usb1: usb_otg_ss@xxx {
>> +    compatible = "xxx";
>> +    reg = <xxx>;
>> +    .
>> +    .
>> +    phys = <&usb2_phy>, <&usb3_phy>;
>> +    phy-names = "usb2phy", "usb3phy";
>> +    .
>> +    .
>> +};
>> +
>> +This node represents a controller that uses two PHYs one for usb2 and one for
>> +usb3.
>> +
>> +Example 2:
>> +usb2: usb_otg_ss@xxx {
>> +    compatible = "xxx";
>> +    reg = <xxx>;
>> +    .
>> +    .
>> +    phys = <&phys 1>;
>> +    .
>> +    .
>> +};
>> +
>> +This node represents a controller that uses one of the PHYs which is defined
>> +previously. Note that the phy handle has an additional specifier "1" to
>> +differentiate between the two PHYs.
>> diff --git a/Documentation/phy.txt b/Documentation/phy.txt
>> new file mode 100644
>> index 0000000..7785ec0
>> --- /dev/null
>> +++ b/Documentation/phy.txt
>> @@ -0,0 +1,113 @@
>> +			    PHY SUBSYSTEM
>> +		  Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
>> +
>> +This document explains the Generic PHY Framework along with the APIs provided,
>> +and how-to-use.
>> +
>> +1. Introduction
>> +
>> +*PHY* is the abbreviation for physical layer. It is used to connect a device
>> +to the physical medium e.g., the USB controller has a PHY to provide functions
>> +such as serialization, de-serialization, encoding, decoding and is responsible
>> +for obtaining the required data transmission rate. Note that some USB
>> +controller has PHY functionality embedded into it and others use an external
>> +PHY. Other peripherals that uses a PHY include Wireless LAN, Ethernet,
>> +SATA etc.
>> +
>> +The intention of creating this framework is to bring the phy drivers spread
>> +all over the Linux kernel to drivers/phy to increase code re-use and to
>> +increase code maintainability.
>> +
>> +This framework will be of use only to devices that uses external PHY (PHY
>> +functionality is not embedded within the controller).
>> +
>> +2. Creating the PHY
>> +
>> +The PHY driver should create the PHY in order for other peripheral controllers
>> +to make use of it. The PHY framework provides 2 APIs to create the PHY.
>> +
>> +struct phy *phy_create(struct device *dev, const char *label,
>> +	struct device_node *of_node, int type, struct phy_ops *ops,
>> +	void *priv);
>> +struct phy *devm_phy_create(struct device *dev, const char *label,
>> +	struct device_node *of_node, int type, struct phy_ops *ops,
>> +	void *priv);
>> +
>> +The PHY drivers can use one of the above 2 APIs to create the PHY by passing
>> +the device pointer, label, device node, type, phy ops and a driver data.
>> +phy_ops is a set of function pointers for performing PHY operations such as
>> +init, exit, suspend, resume, power_on and power_off.
>> +
>> +3. Binding the PHY to the controller
>> +
>> +The framework provides an API for binding the controller to the PHY in the
>> +case of non dt boot.
>> +
>> +struct phy_bind *phy_bind(const char *dev_name, int index,
>> +				const char *phy_dev_name);
>> +
>> +The API fills the phy_bind structure with the dev_name (device name of the
>> +controller), index and phy_dev_name (device name of the PHY). This will
>> +be used when the controller requests this phy. This API should be used by
>> +platform specific initialization code (board file).
>> +
>> +In the case of dt boot, the binding information should be added in the dt
>> +data of the controller.
>> +
>> +4. Getting a reference to the PHY
>> +
>> +Before the controller can make use of the PHY, it has to get a reference to
>> +it. This framework provides 6 APIs to get a reference to the PHY.
>> +
>> +struct phy *phy_get(struct device *dev, int index);
>> +struct phy *devm_phy_get(struct device *dev, int index);
>> +struct phy *of_phy_get(struct device *dev, const char *phandle, int index);
>> +struct phy *devm_of_phy_get(struct device *dev, const char *phandle, int index);
>> +struct phy *of_phy_get_byname(struct device *dev, const char *string);
>> +struct phy *devm_of_phy_get_byname(struct device *dev, const char *string);
>> +
>> +phy_get and devm_phy_get can be used to get the PHY in non-dt boot. This API
>> +uses the binding information added using the phy_bind API to find and return
>> +the appropriate PHY. The only difference between the two APIs is that
>> +devm_phy_get associates the device with the PHY using devres on successful PHY
>> +get. On driver detach, release function is invoked on the the devres data and
>> +devres data is freed.
>> +
>> +of_phy_get and devm_of_phy_get can be used to get the PHY in dt boot. These
>> +APIs take the phandle and index to get a reference to the PHY. The only
>> +difference between the two APIs is that devm_of_phy_get associates the device
>> +with the PHY using devres on successful phy get. On driver detach, release
>> +function is invoked on the devres data and it is freed.
>> +
>> +of_phy_get_byname and devm_of_phy_get_byname can also be used to get the PHY
>> +in dt boot. It is same as the above API except that the user has to pass the
>> +phy name as filled in "phy-names" phandle in dt data and the framework will
>> +find the index and get the PHY.
>> +
>> +5. Releasing a reference to the PHY
>> +
>> +When the controller no longer needs the PHY, it has to release the reference
>> +to the PHY it has obtained using the APIs mentioned in the above section. The
>> +PHY framework provides 2 APIS to release a reference to the PHY.
>> +
>> +void phy_put(struct phy *phy);
>> +void devm_phy_put(struct device *dev, struct phy *phy);
>> +
>> +Both these APIs are used to release a reference to the PHY and devm_phy_put
>> +destroys the devres associated with this PHY.
>> +
>> +6. Destroying the PHY
>> +
>> +When the driver that created the PHY is unloaded, it should destroy the PHY it
>> +created using one of the following 2 APIs.
>> +
>> +void phy_destroy(struct phy *phy);
>> +void devm_phy_destroy(struct device *dev, struct phy *phy);
>> +
>> +Both these APIs destroys the PHY and devm_phy_destroy destroys the devres
>> +associated with this PHY.
>> +
>> +7. DeviceTree Binding
>> +
>> +The documentation for PHY dt binding can be found @
>> +Documentation/devicetree/bindings/phy/phy-bindings.txt
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 72b0843..f2674e7 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -3474,6 +3474,13 @@ S:	Maintained
>>   F:	include/asm-generic
>>   F:	include/uapi/asm-generic
>>
>> +GENERIC PHY FRAMEWORK
>> +M:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
>> +L:	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> +S:	Supported
>> +F:	drivers/phy/
>> +F:	include/linux/phy/
>> +
>>   GENERIC UIO DRIVER FOR PCI DEVICES
>>   M:	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>   L:	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> diff --git a/drivers/Kconfig b/drivers/Kconfig
>> index 202fa6d..ad2c374a 100644
>> --- a/drivers/Kconfig
>> +++ b/drivers/Kconfig
>> @@ -162,4 +162,6 @@ source "drivers/irqchip/Kconfig"
>>
>>   source "drivers/ipack/Kconfig"
>>
>> +source "drivers/phy/Kconfig"
>> +
>>   endmenu
>> diff --git a/drivers/Makefile b/drivers/Makefile
>> index dce39a9..9da8321 100644
>> --- a/drivers/Makefile
>> +++ b/drivers/Makefile
>> @@ -45,6 +45,8 @@ obj-y				+= char/
>>   # gpu/ comes after char for AGP vs DRM startup
>>   obj-y				+= gpu/
>>
>> +obj-y				+= phy/
>> +
>>   obj-$(CONFIG_CONNECTOR)		+= connector/
>>
>>   # i810fb and intelfb depend on char/agp/
>> diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
>> new file mode 100644
>> index 0000000..5f85909
>> --- /dev/null
>> +++ b/drivers/phy/Kconfig
>> @@ -0,0 +1,13 @@
>> +#
>> +# PHY
>> +#
>> +
>> +menuconfig GENERIC_PHY
>> +	tristate "PHY Subsystem"
>> +	help
>> +	  Generic PHY support.
>> +
>> +	  This framework is designed to provide a generic interface for PHY
>> +	  devices present in the kernel. This layer will have the generic
>> +	  API by which phy drivers can create PHY using the phy framework and
>> +	  phy users can obtain reference to the PHY.
>> diff --git a/drivers/phy/Makefile b/drivers/phy/Makefile
>> new file mode 100644
>> index 0000000..9e9560f
>> --- /dev/null
>> +++ b/drivers/phy/Makefile
>> @@ -0,0 +1,5 @@
>> +#
>> +# Makefile for the phy drivers.
>> +#
>> +
>> +obj-$(CONFIG_GENERIC_PHY)	+= phy-core.o
>> diff --git a/drivers/phy/phy-core.c b/drivers/phy/phy-core.c
>> new file mode 100644
>> index 0000000..1d753f2
>> --- /dev/null
>> +++ b/drivers/phy/phy-core.c
>> @@ -0,0 +1,616 @@
>> +/*
>> + * phy-core.c  --  Generic Phy framework.
>> + *
>> + * Copyright (C) 2013 Texas Instruments
>> + *
>> + * Author: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
>> + *
>> + * This program is free software; you can redistribute  it and/or modify it
>> + * under  the terms of  the GNU General  Public License as published by the
>> + * Free Software Foundation;  either version 2 of the  License, or (at your
>> + * option) any later version.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/export.h>
>> +#include <linux/module.h>
>> +#include <linux/err.h>
>> +#include <linux/device.h>
>> +#include <linux/slab.h>
>> +#include <linux/of.h>
>> +#include <linux/phy/phy.h>
>> +
>> +static struct class *phy_class;
>> +static DEFINE_MUTEX(phy_bind_mutex);
>> +static LIST_HEAD(phy_bind_list);
>> +static int phy_core_init(void);
>> +
>> +static void devm_phy_release(struct device *dev, void *res)
>> +{
>> +	struct phy *phy = *(struct phy **)res;
>> +
>> +	phy_put(phy);
>> +}
>> +
>> +static void devm_phy_consume(struct device *dev, void *res)
>> +{
>> +	struct phy *phy = *(struct phy **)res;
>> +
>> +	phy_destroy(phy);
>> +}
>> +
>> +static int devm_phy_match(struct device *dev, void *res, void *match_data)
>> +{
>> +	return res == match_data;
>> +}
>> +
>> +static struct phy *phy_lookup(struct device *dev, int index)
>> +{
>> +	struct phy_bind *phy_bind = NULL;
>> +
>> +	list_for_each_entry(phy_bind, &phy_bind_list, list) {
>> +		if (!(strcmp(phy_bind->dev_name, dev_name(dev)) &&
>> +				phy_bind->index == index)) {
>> +			if (phy_bind->phy)
>> +				return phy_bind->phy;
>> +			else
>> +				return ERR_PTR(-EPROBE_DEFER);
>> +		}
>> +	}
>> +
>> +	return ERR_PTR(-ENODEV);
>> +}
>> +
>> +static struct phy *of_phy_lookup(struct device_node *node)
>> +{
>> +	struct phy *phy;
>> +	struct device *dev;
>> +	struct class_dev_iter iter;
>> +
>> +	class_dev_iter_init(&iter, phy_class, NULL, NULL);
>> +	while ((dev = class_dev_iter_next(&iter))) {
>> +		phy = container_of(dev, struct phy, dev);
>
> it would look a bit better if you provided a to_phy() macro. Specially
> since this container_of() repeats multiple times in this file.

hmm.. ok.
>
>> +/**
>> + * phy_put() - release the PHY
>> + * @phy: the phy returned by phy_get()
>> + *
>> + * Releases a refcount the caller received from phy_get().
>> + */
>> +void phy_put(struct phy *phy)
>> +{
>
> I would rather:
>
> if (WARN(IS_ERR(phy), "invalid parameter\n"))
> 	return;
>
> module_put(phy->ops->owner);
> put_device(&phy->dev);
>
> that way we can catch users passing bogus pointers here. When PHY layer
> is disabled, you want to make this is no-op with a static inline in a
> header anyway.

yeah. Have that no-op in header file.
>
>> +struct phy *of_phy_xlate(struct phy *phy, struct of_phandle_args *args)
>> +{
>> +	return phy;
>> +}
>> +EXPORT_SYMBOL_GPL(of_phy_xlate);
>
> so you get a PHY and just return it ? What gives ?? (maybe I skipped
> some of the discussion...)

hmm.. this is for the common case where the PHY provider implements only 
one PHY. And both phy provider and phy_instance is represented by struct 
phy *.

For the case where PHY provider implements multiple PHYs (here it will 
have a single dt node), the PHY provider will implement it's own version 
of of_xlate that takes *of_phandle_args* as argument and finds the 
appropriate PHY.
>
>> +struct phy *of_phy_get(struct device *dev, int index)
>> +{
>> +	int ret;
>> +	struct phy *phy = NULL;
>> +	struct phy_bind *phy_map = NULL;
>> +	struct of_phandle_args args;
>> +	struct device_node *node;
>> +
>> +	if (!dev->of_node) {
>> +		dev_dbg(dev, "device does not have a device node entry\n");
>> +		return ERR_PTR(-EINVAL);
>> +	}
>> +
>> +	ret = of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
>> +		index, &args);
>> +	if (ret) {
>> +		dev_dbg(dev, "failed to get phy in %s node\n",
>> +			dev->of_node->full_name);
>> +		return ERR_PTR(-ENODEV);
>> +	}
>> +
>> +	phy = of_phy_lookup(args.np);
>> +	if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
>> +		phy = ERR_PTR(-EPROBE_DEFER);
>> +		goto err0;
>> +	}
>> +
>> +	phy = phy->ops->of_xlate(phy, &args);
>
> alright, so of_xlate() is optional, am I right ? How about not

Not really. of_xlate is mandatory (it's even checked in phy_create). 
Either the PHY provider can implement it's own version or use the 
implementation above (by filling the function pointer).

> implementing the above and have a check for of_xlate() being a valid
> pointer here ?

Having the way it is actually mandates the PHY providers to always 
provide of_xlate which IMO is better since some PHY providers wont 
accidentally be using the default implementation.
>
>> +struct phy *phy_create(struct device *dev, const char *label,
>> +	struct device_node *of_node, int type, struct phy_ops *ops,
>> +	void *priv)
>> +{
>> +	int ret;
>> +	struct phy *phy;
>> +	struct phy_bind *phy_bind;
>> +	const char *devname = NULL;
>> +
>> +	if (!dev) {
>> +		dev_err(dev, "no device provided for PHY\n");
>
> I'd call this a WARN() or am I too pedantic? :-p
>
>> +	if (!ops || !ops->of_xlate || !priv) {
>> +		dev_err(dev, "no PHY ops/PHY data provided\n");
>
> likewise here.

hmm.. ok.
>
>> +		ret = -EINVAL;
>> +		goto err0;
>> +	}
>> +
>> +	if (!phy_class)
>> +		phy_core_init();
>
> why don't you setup the class on module_init ? Then this would be a
> terrible error condition here :-)

This is for the case where the PHY driver gets loaded before the PHY 
framework. I could have returned EPROBE_DEFER here instead I thought 
will have it this way.
>
>> +static struct device_attribute phy_dev_attrs[] = {
>> +	__ATTR(label, 0444, phy_name_show, NULL),
>> +	__ATTR(phy_bind, 0444, phy_bind_show, NULL),
>
> you could expose a human-readable 'type' string. BTW, how are you using
> type ? USB2/USB3/etc ? Have you considered our OMAP5 SerDes pair which

Actually not using *type* anywhere. Just used as an additional info 
about the PHY. It's actually not even enum. Maybe I can remove it 
completely.
> are currently for USB3 and SATA (and could just as easily be used for
> PCIe)

Yeah. Me and Balaji were planning to work on it for having a single 
driver to be used for all the above.
>
>> +static void phy_release(struct device *dev)
>> +{
>> +	struct phy *phy;
>> +
>> +	phy = container_of(dev, struct phy, dev);
>> +	dev_dbg(dev, "releasing '%s'\n", dev_name(dev));
>
> how about dev_vdbg() ? I doubt anyone will be waiting for this
> message... Just a thought
>
>> +static int phy_core_init(void)
>> +{
>> +	if (phy_class)
>> +		return 0;
>
> Weird.. if you initialize the class here, why do you need to initialize
> it during phy_create() ?
>
> What's going on ? Also, module_init() will only be called once, why this
> if (phy_class) check ?

er.. for the case where phy driver is loaded before this PHY framework, 
phy_create would have already called phy_core_init to create the 
phy_class. So module_init() is not needed at all since we have already 
created the phy_class. I think this looks a bit hacky.
Either we can have EPROBE_DEFER in phy_create or have this module as 
subsys_initcall() like I had it before. I would actually prefer it to be 
subsys_initcall().

Thanks
Kishon
