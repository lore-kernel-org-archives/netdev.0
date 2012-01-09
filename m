From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Mon, 9 Jan 2012 18:49:43 +0000
Message-ID: <1326134983.2930.19.camel@bwh-desktop>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
	 <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
	 <1325788584.3764.28.camel@bwh-desktop>
	 <F6FB0E698C9B3143BDF729DF22286646027184@ORSMSX102.amr.corp.intel.com>
	 <CAHXqBF+ZY-KH8hOi+QnDZVHx+8OOqP5CLXR44YtDLB3=1DDEOA@mail.gmail.com>
	 <363B5007A0D944459CBE9CF6A37B891B01E292@ORSMSX104.amr.corp.intel.com>
	 <1325873362.2850.20.camel@bwh-desktop>
	 <363B5007A0D944459CBE9CF6A37B891B01E718@ORSMSX104.amr.corp.intel.com>
	 <1325874309.25896.2.camel@bwh-desktop>
	 <363B5007A0D944459CBE9CF6A37B891B01FB58@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Fh8KWK7mboEuWyvQZlF3"
Cc: Michal Miroslaw <mirqus@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:60868 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932525Ab2AIStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 13:49:47 -0500
In-Reply-To: <363B5007A0D944459CBE9CF6A37B891B01FB58@ORSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-Fh8KWK7mboEuWyvQZlF3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

On Mon, 2012-01-09 at 18:08 +0000, Waskiewicz Jr, Peter P wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Ben Hutchings
> > Sent: Friday, January 06, 2012 10:25 AM
> > To: Waskiewicz Jr, Peter P
> > Cc: Michal Miroslaw; Skidmore, Donald C; Kirsher, Jeffrey T;
> > davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> > sassmann@redhat.com
> > Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
> > 
> > On Fri, 2012-01-06 at 18:20 +0000, Waskiewicz Jr, Peter P wrote:
> > > > -----Original Message-----
> > > > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > > > Sent: Friday, January 06, 2012 10:09 AM
> > > > To: Waskiewicz Jr, Peter P
> > > > Cc: Michal Miroslaw; Skidmore, Donald C; Kirsher, Jeffrey T;
> > > > davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> > > > sassmann@redhat.com
> > > > Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal
> > > > data
> > > >
> > > > On Fri, 2012-01-06 at 17:55 +0000, Waskiewicz Jr, Peter P wrote:
> > > > > > -----Original Message-----
> > > > > > From: Michał Mirosław [mailto:mirqus@gmail.com]
> > > > > > Sent: Thursday, January 05, 2012 3:51 PM
> > > > > > To: Skidmore, Donald C
> > > > > > Cc: Ben Hutchings; Kirsher, Jeffrey T; davem@davemloft.net;
> > > > > > netdev@vger.kernel.org; gospo@redhat.com;
> > sassmann@redhat.com;
> > > > > > Waskiewicz Jr, Peter P
> > > > > > Subject: Re: [net-next 8/9] ixgbe: add interface to export
> > > > > > thermal data
> > > > > >
> > > > > > Drivers outside of drivers/hwmon just select HWMON in Kconfig.
> > > > > > This adds a 3kB .c file to the kernel build for the first one that needs it.
> > > > >
> > > > > This is where we run into issues though.  We can put this
> > > > > dependency in, but customers don't pull upstream kernels, they
> > > > > rely on the OSV's to distribute updates.  The customer doesn't
> > > > > want HWMON, and if their kernel doesn't ship with HWMON support
> > for ixgbe, then we're sunk.
> > > >
> > > > So if !IS_ENABLED(CONFIG_HWMON), don't try to create an hwmon
> > > > device, but create the attributes anyway.
> > >
> > > And if CONFIG_HWMON is not enabled, are we then responsible for
> > > creating the hwmon area in sysfs to link in our attributes?  That
> > > would make even less sense to include HWMON attributes if HWMON isn't
> > > built in.
> > 
> > No, the attributes actually appear under the parent device.
> 
> Ok, so how we have it now in the current patches.

Only with different names.

> > > > > The point is what we're trying to implement, based on what our
> > customers'
> > > > > requirements are, is something completely different than what
> > > > > HWMON is providing.  Trying to wedge HWMON onto this framework
> > > > > we're trying to provide just overcomplicates the entire thing we're trying
> > to provide.
> > > > > It's a generic interface to generic data in our drivers,
> > > > [...]
> > > >
> > > > It sounds like you want to provide a "generic" ixgbe interface on
> > > > different operating systems.  But that is not a valid argument for an in-
> > tree driver.
> > >
> > > No, we're trying to provide a generic ixgbe interface on Linux
> > > systems.  The reality is different OSV's pull our driver from upstream
> > > to build their distros,
> > 
> > Yes we know.
> > 
> > [...]
> > > The reality is these attributes of our thermal sensors are about 5% of
> > > the data we need to export.
> > [...]
>
> > And I think all you need to do is (1) give these particular attributes the right
> > names and (2) create a child hwmon device if possible.  Is that so hard?
> 
> Yes, it is.  The sensors that we have defined for this SKU are defined
> by the customers who this board was built for, so it fits with their
> BMC.  We don't have much control over the names.

You should expose the names as '<type><index>_label' attributes.

> Again, I'm failing to see why you are requiring us to put in this
> support when we don't benefit at all from it, we don't need it, and
> don't want it.  Perhaps you can add the HWMON support to ixgbe when
> you get around to adding the same support to your Solarflare driver
> that hasn't been completed yet?

I already did that for the SFC4000 boards, using existing hwmon drivers.
I'm attaching the implementation for SFC9000-family boards (though it's
not immediately applicable as it needs an update to the firmware
protocol header).  Oddly enough I'm not inclined to spend time on your
boards!  But maybe this can serve as an example of how to expose sensors
that are discoverd at run-time.

> We'd be happy to accept those patches.  Please don't hold us to a
> standard you won't hold your own driver to.

I'm not the one proposing to add a driver-specific interface for
something that's already standardised!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-Fh8KWK7mboEuWyvQZlF3
Content-Disposition: attachment;
	filename*0="0001-sfc-Add-hardware-monitor-for-sensors-managed-by-firm.pat";
	filename*1="ch"
Content-Type: text/x-patch;
	name="0001-sfc-Add-hardware-monitor-for-sensors-managed-by-firm.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From a64b65e8e5efee3b176ae395e30132bff7564440 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 6 Jan 2012 20:25:39 +0000
Subject: [PATCH net-next] sfc: Add hardware monitor for sensors managed by
 firmware
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig    |    7 +
 drivers/net/ethernet/sfc/Makefile   |    1 +
 drivers/net/ethernet/sfc/mcdi.h     |   27 +++
 drivers/net/ethernet/sfc/mcdi_mon.c |  368 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/nic.h      |   14 ++
 drivers/net/ethernet/sfc/siena.c    |    6 +
 6 files changed, 423 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/mcdi_mon.c

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 5d18841..ae40b66 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -19,3 +19,10 @@ config SFC_MTD
 	  This exposes the on-board flash memory as MTD devices (e.g.
 	  /dev/mtd1).  This makes it possible to upload new firmware
 	  to the NIC.
+config SFC_MCDI_MON
+	bool "Solarflare SFC9000-family hwmon support"
+	depends on SFC && HWMON && !(SFC=y && HWMON=m)
+	default y
+	----help---
+	  This exposes the on-board firmware-managed sensors as a
+	  hardware monitor device.
diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index ab31c71..3a1aa84 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -4,5 +4,6 @@ sfc-y			+= efx.o nic.o falcon.o siena.o tx.o rx.o filter.o \
 			   tenxpress.o txc43128_phy.o falcon_boards.o \
 			   mcdi.o mcdi_phy.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
+sfc-$(CONFIG_SFC_MCDI_MON) += mcdi_mon.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 4dd39fc..0af1bd4 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -56,6 +56,15 @@ struct efx_mcdi_iface {
 	size_t resplen;
 };
 
+struct efx_mcdi_mon {
+	struct efx_buffer dma_buf;
+	struct mutex update_lock;
+	unsigned long last_update;
+	struct device *device;
+	struct efx_mcdi_mon_attribute *attrs;
+	unsigned int n_attrs;
+};
+
 extern void efx_mcdi_init(struct efx_nic *efx);
 
 extern int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd, const u8 *inbuf,
@@ -83,6 +92,10 @@ extern void efx_mcdi_process_event(struct efx_channel *channel,
 
 #define MCDI_PTR(_buf, _ofst)						\
 	MCDI_PTR2(_buf, MC_CMD_ ## _ofst ## _OFST)
+#define MCDI_ARRAY_PTR(_buf, _field, _type, _index)			\
+	MCDI_PTR2(_buf,							\
+		  MC_CMD_ ## _field ## _OFST +				\
+		  (_index) * MC_CMD_ ## _type ## _TYPEDEF_LEN)
 #define MCDI_SET_DWORD(_buf, _ofst, _value)				\
 	MCDI_SET_DWORD2(_buf, MC_CMD_ ## _ofst ## _OFST, _value)
 #define MCDI_DWORD(_buf, _ofst)						\
@@ -92,6 +105,12 @@ extern void efx_mcdi_process_event(struct efx_channel *channel,
 
 #define MCDI_EVENT_FIELD(_ev, _field)			\
 	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
+#define MCDI_ARRAY_FIELD(_buf, _field1, _type, _index, _field2)		\
+	EFX_DWORD_FIELD(						\
+		*((efx_dword_t *)					\
+		  (MCDI_ARRAY_PTR(_buf, _field1, _type, _index) +	\
+		   (MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _OFST & ~3))), \
+		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2)
 
 extern void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len);
 extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
@@ -131,4 +150,12 @@ extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 extern int efx_mcdi_mac_reconfigure(struct efx_nic *efx);
 extern bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 
+#ifdef CONFIG_SFC_MCDI_MON
+extern int efx_mcdi_mon_probe(struct efx_nic *efx);
+extern void efx_mcdi_mon_remove(struct efx_nic *efx);
+#else
+static inline int efx_mcdi_mon_probe(struct efx_nic *efx) { return 0; }
+static inline void efx_mcdi_mon_remove(struct efx_nic *efx) {}
+#endif
+
 #endif /* EFX_MCDI_H */
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
new file mode 100644
index 0000000..ce4e49e
--- /dev/null
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -0,0 +1,368 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/hwmon.h>
+#include <linux/stat.h>
+
+#include "net_driver.h"
+#include "mcdi.h"
+#include "mcdi_pcol.h"
+#include "nic.h"
+
+enum efx_hwmon_type {
+	EFX_HWMON_UNKNOWN,
+	EFX_HWMON_TEMP,         /* temperature */
+	EFX_HWMON_COOL,         /* cooling device, probably a heatsink */
+	EFX_HWMON_IN            /* input voltage */
+};
+
+static const struct {
+	const char *label;
+	enum efx_hwmon_type hwmon_type;
+	int port;
+} efx_mcdi_sensor_type[MC_CMD_SENSOR_ENTRY_MAXNUM] = {
+#define SENSOR_TYPE(name, label, hwmon_type, port)			\
+	[MC_CMD_SENSOR_##name] = { label, hwmon_type, port }
+	SENSOR_TYPE(CONTROLLER_TEMP,	"NIC temp.",	EFX_HWMON_TEMP,	-1),
+	SENSOR_TYPE(PHY_COMMON_TEMP,	"PHY temp.",	EFX_HWMON_TEMP,	-1),
+	SENSOR_TYPE(CONTROLLER_COOLING,	"NIC cooling",	EFX_HWMON_COOL,	-1),
+	SENSOR_TYPE(PHY0_TEMP,		"PHY temp.",	EFX_HWMON_TEMP,	0),
+	SENSOR_TYPE(PHY0_COOLING,	"PHY cooling",	EFX_HWMON_COOL,	0),
+	SENSOR_TYPE(PHY1_TEMP,		"PHY temp.",	EFX_HWMON_TEMP,	1),
+	SENSOR_TYPE(PHY1_COOLING, 	"PHY cooling",	EFX_HWMON_COOL,	1),
+	SENSOR_TYPE(IN_1V0,		"1.0V",		EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_1V2,		"1.2V",		EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_1V8,		"1.8V",		EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_2V5,		"2.5V",		EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_3V3,		"3.3V",		EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_12V0,		"12.0V",	EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_1V2A,		"1.2V analogue", EFX_HWMON_IN,	-1),
+	SENSOR_TYPE(IN_VREF,		"ref. voltage",	EFX_HWMON_IN,	-1),
+};
+
+struct efx_mcdi_mon_attribute {
+	struct device_attribute dev_attr;
+	unsigned int index;
+	unsigned int limit_value;
+	char name[12];
+};
+
+static int efx_mcdi_mon_update(struct efx_nic *efx)
+{
+	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
+	u8 inbuf[MC_CMD_READ_SENSORS_IN_LEN];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, READ_SENSORS_IN_DMA_ADDR_LO,
+		       hwmon->dma_buf.dma_addr & 0xffffffff);
+	MCDI_SET_DWORD(inbuf, READ_SENSORS_IN_DMA_ADDR_HI,
+		       (u64)hwmon->dma_buf.dma_addr >> 32);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_READ_SENSORS,
+			  inbuf, sizeof(inbuf), NULL, 0, NULL);
+	if (rc == 0)
+		hwmon->last_update = jiffies;
+	return rc;
+}
+
+static ssize_t efx_mcdi_mon_show_name(struct device *dev,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	return sprintf(buf, "%s\n", KBUILD_MODNAME);
+}
+
+static int efx_mcdi_mon_get_entry(struct device *dev, unsigned int index,
+				  efx_dword_t *entry)
+{
+	struct efx_nic *efx = dev_get_drvdata(dev);
+	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_READ_SENSORS_OUT_LEN != 0);
+
+	mutex_lock(&hwmon->update_lock);
+
+	/* Use cached value if last update was < 1 s ago */
+	if (time_before(jiffies, hwmon->last_update + HZ))
+		rc = 0;
+	else
+		rc = efx_mcdi_mon_update(efx);
+
+	/* Copy out the requested entry */
+	*entry = ((efx_dword_t *)hwmon->dma_buf.addr)[index];
+
+	mutex_unlock(&hwmon->update_lock);
+
+	return rc;
+}
+
+static ssize_t efx_mcdi_mon_show_value(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct efx_mcdi_mon_attribute *mon_attr =
+		container_of(attr, struct efx_mcdi_mon_attribute, dev_attr);
+	efx_dword_t entry;
+	unsigned int value;
+	int rc;
+
+	rc = efx_mcdi_mon_get_entry(dev, mon_attr->index, &entry);
+	if (rc)
+		return rc;
+
+	value = EFX_DWORD_FIELD(entry, MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_VALUE);
+
+	/* Convert temperature from degrees to milli-degrees Celsius */
+	if (efx_mcdi_sensor_type[mon_attr->index].hwmon_type == EFX_HWMON_TEMP)
+		value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t efx_mcdi_mon_show_limit(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct efx_mcdi_mon_attribute *mon_attr =
+		container_of(attr, struct efx_mcdi_mon_attribute, dev_attr);
+	unsigned int value;
+
+	value = mon_attr->limit_value;
+
+	/* Convert temperature from degrees to milli-degrees Celsius */
+	if (efx_mcdi_sensor_type[mon_attr->index].hwmon_type == EFX_HWMON_TEMP)
+		value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t efx_mcdi_mon_show_alarm(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct efx_mcdi_mon_attribute *mon_attr =
+		container_of(attr, struct efx_mcdi_mon_attribute, dev_attr);
+	efx_dword_t entry;
+	int state;
+	int rc;
+
+	rc = efx_mcdi_mon_get_entry(dev, mon_attr->index, &entry);
+	if (rc)
+		return rc;
+
+	state = EFX_DWORD_FIELD(entry, MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_STATE);
+	return sprintf(buf, "%d\n", state != MC_CMD_SENSOR_STATE_OK);
+}
+
+static ssize_t efx_mcdi_mon_show_label(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct efx_mcdi_mon_attribute *mon_attr =
+		container_of(attr, struct efx_mcdi_mon_attribute, dev_attr);
+	return sprintf(buf, "%s\n",
+		       efx_mcdi_sensor_type[mon_attr->index].label);
+}
+
+static int
+efx_mcdi_mon_add_attr(struct efx_nic *efx, const char *name,
+		      ssize_t (*reader)(struct device *,
+					struct device_attribute *, char *),
+		      unsigned int index, unsigned int limit_value)
+{
+	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
+	struct efx_mcdi_mon_attribute *attr = &hwmon->attrs[hwmon->n_attrs];
+	int rc;
+
+	strlcpy(attr->name, name, sizeof(attr->name));
+	attr->index = index;
+	attr->limit_value = limit_value;
+	attr->dev_attr.attr.name = attr->name;
+	attr->dev_attr.attr.mode = S_IRUGO;
+	attr->dev_attr.show = reader;
+	rc = device_create_file(&efx->pci_dev->dev, &attr->dev_attr);
+	if (rc == 0)
+		++hwmon->n_attrs;
+	return rc;
+}
+
+int efx_mcdi_mon_probe(struct efx_nic *efx)
+{
+	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
+	unsigned int n_attrs, n_temp = 0, n_cool = 0, n_in = 0;
+	u8 outbuf[MC_CMD_SENSOR_INFO_OUT_LENMAX];
+	size_t outlen;
+	char name[12];
+	u32 mask;
+	int rc, i;
+
+	BUILD_BUG_ON(MC_CMD_SENSOR_INFO_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_SENSOR_INFO, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		return rc;
+	if (outlen < MC_CMD_SENSOR_INFO_OUT_LENMIN)
+		return -EIO;
+
+	/* Find out which sensors are present.  Don't create a device
+	 * if there are none.
+	 */
+	mask = MCDI_DWORD(outbuf, SENSOR_INFO_OUT_MASK);
+	if (mask == 0)
+		return 0;
+
+	rc = efx_nic_alloc_buffer(efx, &hwmon->dma_buf,
+				  4 * MC_CMD_SENSOR_ENTRY_MAXNUM);
+	if (rc)
+		return rc;
+
+	mutex_init(&hwmon->update_lock);
+	efx_mcdi_mon_update(efx);
+
+	/* Allocate space for the maximum possible number of
+	 * attributes for this set of sensors: name of the driver plus
+	 * value, min, max, crit, alarm and label for each sensor.
+	 */
+	n_attrs = 1 + 6 * hweight32(mask);
+	hwmon->attrs = kcalloc(n_attrs, sizeof(*hwmon->attrs), GFP_KERNEL);
+	if (!hwmon->attrs) {
+		rc = -ENOMEM;
+		goto fail;
+	}
+
+	hwmon->device = hwmon_device_register(&efx->pci_dev->dev);
+	if (IS_ERR(hwmon->device)) {
+		rc = PTR_ERR(hwmon->device);
+		goto fail;
+	}
+
+	rc = efx_mcdi_mon_add_attr(efx, "name", efx_mcdi_mon_show_name, 0, 0);
+	if (rc)
+		goto fail;
+
+	for (i = 0; MC_CMD_SENSOR_INFO_OUT_LEN(i + 1) <= outlen; i++) {
+		const char *hwmon_prefix;
+		unsigned hwmon_index;
+		u16 min1, max1, min2, max2;
+
+		if (!(mask & (1 << i)))
+			continue;
+
+		/* Skip sensors specific to a different port */
+		if (efx_mcdi_sensor_type[i].hwmon_type != EFX_HWMON_UNKNOWN &&
+		    efx_mcdi_sensor_type[i].port >= 0 &&
+		    efx_mcdi_sensor_type[i].port != efx_port_num(efx))
+			continue;
+
+		switch (efx_mcdi_sensor_type[i].hwmon_type) {
+		case EFX_HWMON_TEMP:
+			hwmon_prefix = "temp";
+			hwmon_index = ++n_temp; /* 1-based */
+			break;
+		case EFX_HWMON_COOL:
+			/* This is likely to be a heatsink, but there
+			 * is no convention for representing cooling
+			 * devices other than fans.
+			 */
+			hwmon_prefix = "fan";
+			hwmon_index = ++n_cool; /* 1-based */
+			break;
+		default:
+			hwmon_prefix = "in";
+			hwmon_index = n_in++; /* 0-based */
+			break;
+		}
+
+		min1 = MCDI_ARRAY_FIELD(outbuf, SENSOR_ENTRY,
+					SENSOR_INFO_ENTRY, i, MIN1);
+		max1 = MCDI_ARRAY_FIELD(outbuf, SENSOR_ENTRY,
+					SENSOR_INFO_ENTRY, i, MAX1);
+		min2 = MCDI_ARRAY_FIELD(outbuf, SENSOR_ENTRY,
+					SENSOR_INFO_ENTRY, i, MIN2);
+		max2 = MCDI_ARRAY_FIELD(outbuf, SENSOR_ENTRY,
+					SENSOR_INFO_ENTRY, i, MAX2);
+
+		if (min1 != max1) {
+			snprintf(name, sizeof(name), "%s%u_input",
+				 hwmon_prefix, hwmon_index);
+			rc = efx_mcdi_mon_add_attr(
+				efx, name, efx_mcdi_mon_show_value, i, 0);
+			if (rc)
+				goto fail;
+
+			snprintf(name, sizeof(name), "%s%u_min",
+				 hwmon_prefix, hwmon_index);
+			rc = efx_mcdi_mon_add_attr(
+				efx, name, efx_mcdi_mon_show_limit, i, min1);
+			if (rc)
+				goto fail;
+
+			snprintf(name, sizeof(name), "%s%u_max",
+				 hwmon_prefix, hwmon_index);
+			rc = efx_mcdi_mon_add_attr(
+				efx, name, efx_mcdi_mon_show_limit, i, max1);
+			if (rc)
+				goto fail;
+
+			if (min2 != max2) {
+				/* Assume max2 is critical value.
+				 * But we have no good way to expose min2.
+				 */
+				snprintf(name, sizeof(name), "%s%u_crit",
+					 hwmon_prefix, hwmon_index);
+				rc = efx_mcdi_mon_add_attr(
+					efx, name, efx_mcdi_mon_show_limit, i,
+					max2);
+				if (rc)
+					goto fail;
+			}
+		}
+
+		snprintf(name, sizeof(name), "%s%u_alarm",
+			 hwmon_prefix, hwmon_index);
+		rc = efx_mcdi_mon_add_attr(
+			efx, name, efx_mcdi_mon_show_alarm, i, 0);
+		if (rc)
+			goto fail;
+
+		if (efx_mcdi_sensor_type[i].label) {
+			snprintf(name, sizeof(name), "%s%u_label",
+				 hwmon_prefix, hwmon_index);
+			rc = efx_mcdi_mon_add_attr(
+				efx, name, efx_mcdi_mon_show_label, i, 0);
+			if (rc)
+				goto fail;
+		}
+	}
+
+	return 0;
+
+fail:
+	efx_mcdi_mon_remove(efx);
+	return rc;
+}
+
+void efx_mcdi_mon_remove(struct efx_nic *efx)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct efx_mcdi_mon *hwmon = &nic_data->hwmon;
+	unsigned int i;
+
+	for (i = 0; i < hwmon->n_attrs; i++)
+		device_remove_file(&efx->pci_dev->dev,
+				   &hwmon->attrs[i].dev_attr);
+	kfree(hwmon->attrs);
+	if (hwmon->device)
+		hwmon_device_unregister(hwmon->device);
+	efx_nic_free_buffer(efx, &hwmon->dma_buf);
+}
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index a3ccd0b..905a187 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -144,12 +144,26 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
  * struct siena_nic_data - Siena NIC state
  * @mcdi: Management-Controller-to-Driver Interface
  * @wol_filter_id: Wake-on-LAN packet filter id
+ * @hwmon: Hardware monitor state
  */
 struct siena_nic_data {
 	struct efx_mcdi_iface mcdi;
 	int wol_filter_id;
+#ifdef CONFIG_SFC_MCDI_MON
+	struct efx_mcdi_mon hwmon;
+#endif
 };
 
+#ifdef CONFIG_SFC_MCDI_MON
+static inline struct efx_mcdi_mon *efx_mcdi_mon(struct efx_nic *efx)
+{
+	struct siena_nic_data *nic_data;
+	EFX_BUG_ON_PARANOID(efx_nic_rev(efx) < EFX_REV_SIENA_A0);
+	nic_data = efx->nic_data;
+	return &nic_data->hwmon;
+}
+#endif
+
 extern const struct efx_nic_type falcon_a1_nic_type;
 extern const struct efx_nic_type falcon_b0_nic_type;
 extern const struct efx_nic_type siena_a0_nic_type;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index f054258..d3c4169 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -300,6 +300,10 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail5;
 	}
 
+	rc = efx_mcdi_mon_probe(efx);
+	if (rc)
+		goto fail5;
+
 	return 0;
 
 fail5:
@@ -387,6 +391,8 @@ static int siena_init_nic(struct efx_nic *efx)
 
 static void siena_remove_nic(struct efx_nic *efx)
 {
+	efx_mcdi_mon_remove(efx);
+
 	efx_nic_free_buffer(efx, &efx->irq_status);
 
 	siena_reset_hw(efx, RESET_TYPE_ALL);
-- 
1.7.7.5


--=-Fh8KWK7mboEuWyvQZlF3--
