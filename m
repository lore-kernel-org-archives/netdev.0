From: Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/34] New SMBIOS driver for x86 and ia64.
Date: Mon, 18 Jul 2011 09:08:16 -0400
Message-ID: <1310994528-26276-3-git-send-email-prarit@redhat.com>
References: <1310994528-26276-1-git-send-email-prarit@redhat.com>
Cc: Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	evel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	device-drivers-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
	dz-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org, rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org, eric.piel-VkQ1JFuSMpfAbQlEx87xDw@public.gmane.org,
	abelay-3s7WtUTddSA@public.gmane.org, johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310994528-26276-1-git-send-email-prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This, along with the System Firmware (sysfw) interface replaces the existing
DMI code in the kernel.

This subsystem provides functionality for individual drivers to access
the SMBIOS structures for their own use, smbios_walk(), as well as some
helper functions for some kernel modules.

Cc: linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Cc: lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Cc: evel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: device-drivers-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Cc: linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org
Cc: dz-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org
Cc: rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org
Cc: eric.piel-VkQ1JFuSMpfAbQlEx87xDw@public.gmane.org
Cc: abelay-3s7WtUTddSA@public.gmane.org
Cc: johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org
Signed-off-by: Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 Documentation/ABI/obsolete/sysfs-dmi   |   40 ++
 Documentation/ABI/testing/sysfw-smbios |   36 ++
 arch/ia64/Kconfig                      |    5 +
 arch/ia64/include/asm/smbios.h         |   12 +
 arch/x86/Kconfig                       |   10 +
 arch/x86/include/asm/smbios.h          |   19 +
 drivers/firmware/Kconfig               |   20 +
 drivers/firmware/Makefile              |    2 +
 drivers/firmware/smbios-sysfs.c        |  705 ++++++++++++++++++++++++++++++++
 drivers/firmware/smbios.c              |  687 +++++++++++++++++++++++++++++++
 include/linux/smbios.h                 |  243 +++++++++++
 11 files changed, 1779 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/sysfs-dmi
 create mode 100644 Documentation/ABI/testing/sysfw-smbios
 create mode 100644 arch/ia64/include/asm/smbios.h
 create mode 100644 arch/x86/include/asm/smbios.h
 create mode 100644 drivers/firmware/smbios-sysfs.c
 create mode 100644 drivers/firmware/smbios.c
 create mode 100644 include/linux/smbios.h

diff --git a/Documentation/ABI/obsolete/sysfs-dmi b/Documentation/ABI/obsolete/sysfs-dmi
new file mode 100644
index 0000000..547dc4b
--- /dev/null
+++ b/Documentation/ABI/obsolete/sysfs-dmi
@@ -0,0 +1,40 @@
+What:		/sys/class/dmi
+Date:		July 2011
+KernelVersion:	3.0
+Contact:	Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+Description:
+		The dmi class is exported if CONFIG_SMBIOS_DMI_COMPAT is
+		set.
+
+		The DMI code currently exposes several values via sysfs.
+		These values are:
+
+		bios_date: The datestamp of the BIOS.
+		bios_vendor: The company that wrote the BIOS.
+		bios_version: The version of the BIOS.
+		board_asset_tag: A unique identifier for the system
+				 motherboard.
+		board_name: The name of the type of motherboard.
+		board_serial: The serial number of the motherboard.
+		board_vendor: The company that designed the motherboard.
+		board_version: The version of the motherboard.
+		chassis_asset_tag: A unique identifier for the chassis.
+		chassis_serial: The serial number of the chassis.
+		chassis_type: The type of chassis.
+		chassis_vendor: The company that designed the chassis.
+		chassis_version: The version of the chassis.
+		product_name: The name of the system as determined by the
+			      OEM.
+		product_serial: The serial number of the system.
+		product_uuid: A unique UUID for the system.
+		product_version: The version number of the system.
+		sys_vendor: The OEM company for the system.
+
+		In addition to these the standard class files are exposed
+		for DMI (uvent, power, subsystem) as well as a modalias
+		file.
+
+		The dmi class is deprecated and should not be used by new
+		code.  Existing code should be migrated to use
+		/sys/class/smbios/* which exposes the same data.
+		The dmi class link will be removed in July of 2013.
diff --git a/Documentation/ABI/testing/sysfw-smbios b/Documentation/ABI/testing/sysfw-smbios
new file mode 100644
index 0000000..c6045f1
--- /dev/null
+++ b/Documentation/ABI/testing/sysfw-smbios
@@ -0,0 +1,36 @@
+What:		/sys/bus/sysfw
+Date:		May 1 2011
+KernelVersion:	2.6.39
+Contact:	Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+Description:
+		The dmi class is exported if CONFIG_SMBIOS is set.
+
+		The SMBIOS code currently exposes several values via sysfs
+		primarily for use by module handling code.
+
+		These values are:
+
+		bios_date: The datestamp of the BIOS.
+		bios_vendor: The company that wrote the BIOS.
+		bios_version: The version of the BIOS.
+		board_asset_tag: A unique identifier for the system
+				 motherboard.
+		board_name: The name of the type of motherboard.
+		board_serial: The serial number of the motherboard.
+		board_vendor: The company that designed the motherboard.
+		board_version: The version of the motherboard.
+		chassis_asset_tag: A unique identifier for the chassis.
+		chassis_serial: The serial number of the chassis.
+		chassis_type: The type of chassis.
+		chassis_vendor: The company that designed the chassis.
+		chassis_version: The version of the chassis.
+		product_name: The name of the system as determined by the
+			      OEM.
+		product_serial: The serial number of the system.
+		product_uuid: A unique UUID for the system.
+		product_version: The version number of the system.
+		sys_vendor: The OEM company for the system.
+
+		In addition to these the standard class files are exposed
+		for SMBIOS (uvent, power, subsystem) as well as a modalias
+		file.
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 38280ef..ac14d3c 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -93,6 +93,11 @@ config DMI
 	bool
 	default y
 
+config SMBIOS
+	bool
+	default y
+	depends on SYSTEM_FIRMWARE
+
 config EFI
 	bool
 	default y
diff --git a/arch/ia64/include/asm/smbios.h b/arch/ia64/include/asm/smbios.h
new file mode 100644
index 0000000..19c0019
--- /dev/null
+++ b/arch/ia64/include/asm/smbios.h
@@ -0,0 +1,12 @@
+#ifndef _ASM_SMBIOS_H
+#define _ASM_SMBIOS_H 1
+
+#include <linux/slab.h>
+#include <asm/io.h>
+
+/* Use normal IO mappings for SMBIOS */
+#define smbios_ioremap ioremap
+#define smbios_iounmap(x, l) iounmap(x)
+#define smbios_alloc(l) kmalloc(l, GFP_ATOMIC)
+
+#endif
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index da34972..e7cdde8 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -635,6 +635,16 @@ config DMI
 	  affected by entries in the DMI blacklist. Required by PNP
 	  BIOS code.
 
+config SMBIOS
+	depends on SYSTEM_FIRMWARE
+	bool "Enable SMBIOS scanning" if EXPERT
+	default y
+	---help---
+	  Enabled scanning of SMBIOS to identify machine quirks. Say Y
+	  here unless you have verified that your setup is not
+	  affected by entries in the SMBIOS blacklist. Required by PNP
+	  BIOS code.
+
 config GART_IOMMU
 	bool "GART IOMMU support" if EXPERT
 	default y
diff --git a/arch/x86/include/asm/smbios.h b/arch/x86/include/asm/smbios.h
new file mode 100644
index 0000000..767270b
--- /dev/null
+++ b/arch/x86/include/asm/smbios.h
@@ -0,0 +1,19 @@
+#ifndef _ASM_X86_SMBIOS_H
+#define _ASM_X86_SMBIOS_H
+
+#include <linux/compiler.h>
+#include <linux/init.h>
+
+#include <asm/io.h>
+#include <asm/setup.h>
+
+static __always_inline __init void *smbios_alloc(unsigned len)
+{
+	return extend_brk(len, sizeof(int));
+}
+
+/* Use early IO mappings for SMBIOS because it's initialized early */
+#define smbios_ioremap early_ioremap
+#define smbios_iounmap early_iounmap
+
+#endif /* _ASM_X86_SMBIOS_H */
diff --git a/drivers/firmware/Kconfig b/drivers/firmware/Kconfig
index 79a1b9d..23066d8 100644
--- a/drivers/firmware/Kconfig
+++ b/drivers/firmware/Kconfig
@@ -182,6 +182,26 @@ config SYSTEM_FIRMWARE_DMI_COMPAT
 	  should not be used in new user space software.  Please see
 	  Documentation/ABI for details.
 
+config SYSTEM_FIRMWARE_DMI_COMPAT
+	bool "Export dmi compatibility class in sysfs"
+	depends on SMBIOSID
+	default y
+	help
+	  This exposes /sys/class/dmi/* as a pointer to the sysfw class for
+	  old software.  This is purely a backwards compatability feature and
+	  should not be used in new user space software.  Please see
+	  Documentation/ABI for details.
+
+config SMBIOS_SYSFS
+	tristate "SMBIOS table support in sysfs"
+	depends on SYSFS && SMBIOS
+	help
+	  Say Y or M here to enable the exporting of the raw SMBIOS table
+	  data via sysfs.  This is useful for consuming the data without
+	  requiring any access to /dev/mem at all.  Tables are found
+	  under /sys/firmware/smbios when this option is enabled and
+	  loaded.
+
 source "drivers/firmware/google/Kconfig"
 
 endmenu
diff --git a/drivers/firmware/Makefile b/drivers/firmware/Makefile
index 41bc64a..5c9d81f 100644
--- a/drivers/firmware/Makefile
+++ b/drivers/firmware/Makefile
@@ -16,3 +16,5 @@ obj-$(CONFIG_SIGMA)		+= sigma.o
 obj-$(CONFIG_GOOGLE_FIRMWARE)	+= google/
 obj-$(CONFIG_SYSTEM_FIRMWARE)	+= sysfw.o
 obj-$(CONFIG_SYSTEM_FIRMWARE_SYSFS)	+= sysfw-sysfs.o
+obj-$(CONFIG_SMBIOS)		+= smbios.o
+obj-$(CONFIG_SMBIOS_SYSFS)	+= smbios-sysfs.o
diff --git a/drivers/firmware/smbios-sysfs.c b/drivers/firmware/smbios-sysfs.c
new file mode 100644
index 0000000..9fd36a6
--- /dev/null
+++ b/drivers/firmware/smbios-sysfs.c
@@ -0,0 +1,705 @@
+/*
+ * smbios-sysfs.c
+ *
+ * This module exports the SMBIOS tables read-only to userspace through the
+ * sysfs file system.
+ *
+ * Data is currently found below
+ *    /sys/firmware/smbios/...
+ *
+ * SMBIOS attributes are presented in attribute files with names
+ * formatted using %d-%d, so that the first integer indicates the
+ * structure type (0-255), and the second field is the instance of that
+ * entry.
+ *
+ * Copyright 2011 Google, Inc.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kobject.h>
+#include <linux/smbios.h>
+#include <linux/capability.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/io.h>
+
+#define MAX_ENTRY_TYPE 255 /* Most of these aren't used, but we consider
+			      the top entry type is only 8 bits */
+
+struct smbios_sysfs_entry {
+	struct smbios_header dh;
+	struct kobject kobj;
+	int instance;
+	int position;
+	struct list_head list;
+	struct kobject *child;
+};
+
+/*
+ * Global list of smbios_sysfs_entry.  Even though this should only be
+ * manipulated at setup and teardown, the lazy nature of the kobject
+ * system means we get lazy removes.
+ */
+static LIST_HEAD(entry_list);
+static DEFINE_SPINLOCK(entry_list_lock);
+
+/* smbios_sysfs_attribute - Top level attribute. used by all entries. */
+struct smbios_sysfs_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct smbios_sysfs_entry *entry, char *buf);
+};
+
+#define SMBIOS_SYSFS_ATTR(_entry, _name) \
+struct smbios_sysfs_attribute smbios_sysfs_attr_##_entry##_##_name = { \
+	.attr = {.name = __stringify(_name), .mode = 0400}, \
+	.show = smbios_sysfs_##_entry##_##_name, \
+}
+
+/*
+ * smbios_sysfs_mapped_attribute - Attribute where we require the entry be
+ * mapped in.  Use in conjunction with smbios_sysfs_specialize_attr_ops.
+ */
+struct smbios_sysfs_mapped_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct smbios_sysfs_entry *entry,
+			const struct smbios_header *dh,
+			char *buf);
+};
+
+#define SMBIOS_SYSFS_MAPPED_ATTR(_entry, _name) \
+struct smbios_sysfs_mapped_attribute smbios_sysfs_attr_##_entry##_##_name = { \
+	.attr = {.name = __stringify(_name), .mode = 0400}, \
+	.show = smbios_sysfs_##_entry##_##_name, \
+}
+
+/*************************************************
+ * Generic SMBIOS entry support.
+ *************************************************/
+static void smbios_entry_free(struct kobject *kobj)
+{
+	kfree(kobj);
+}
+
+static struct smbios_sysfs_entry *to_entry(struct kobject *kobj)
+{
+	return container_of(kobj, struct smbios_sysfs_entry, kobj);
+}
+
+static struct smbios_sysfs_attribute *to_attr(struct attribute *attr)
+{
+	return container_of(attr, struct smbios_sysfs_attribute, attr);
+}
+
+static ssize_t smbios_sysfs_attr_show(struct kobject *kobj,
+				      struct attribute *_attr, char *buf)
+{
+	struct smbios_sysfs_entry *entry = to_entry(kobj);
+	struct smbios_sysfs_attribute *attr = to_attr(_attr);
+
+	/* SMBIOS stuff is only ever admin visible */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	return attr->show(entry, buf);
+}
+
+static const struct sysfs_ops smbios_sysfs_attr_ops = {
+	.show = smbios_sysfs_attr_show,
+};
+
+typedef ssize_t (*smbios_callback)(struct smbios_sysfs_entry *,
+				   const struct smbios_header *dh, void *);
+
+struct find_smbios_data {
+	struct smbios_sysfs_entry	*entry;
+	smbios_callback		callback;
+	void			*private;
+	int			instance_countdown;
+	ssize_t			ret;
+};
+
+static int find_smbios_entry_helper(const union smbios_struct *ss, void *_data)
+{
+	struct find_smbios_data *data = _data;
+	struct smbios_sysfs_entry *entry = data->entry;
+
+	/* Is this the entry we want? */
+	if (ss->header.type != entry->dh.type)
+		return SMBIOS_WALK_CONTINUE;
+
+	if (data->instance_countdown != 0) {
+		/* try the next instance? */
+		data->instance_countdown--;
+		return SMBIOS_WALK_CONTINUE;
+	}
+
+	/*
+	 * Don't ever revisit the instance.  Short circuit later
+	 * instances by letting the instance_countdown run negative
+	 */
+	data->instance_countdown--;
+
+	/* Found the entry */
+	data->ret = data->callback(entry, &ss->header, data->private);
+
+	return SMBIOS_WALK_STOP;
+}
+
+/* State for passing the read parameters through smbios_find_entry() */
+struct smbios_read_state {
+	char *buf;
+	loff_t pos;
+	size_t count;
+};
+
+static ssize_t find_smbios_entry(struct smbios_sysfs_entry *entry,
+				 smbios_callback callback, void *private)
+{
+	struct find_smbios_data data = {
+		.entry = entry,
+		.callback = callback,
+		.private = private,
+		.instance_countdown = entry->instance,
+		.ret = -EIO,  /* To signal the entry disappeared */
+	};
+	const union smbios_struct *ss;
+
+	ss = smbios_walk(find_smbios_entry_helper, &data);
+	if (!ss)
+		return -EINVAL;
+	return data.ret;
+}
+
+/*
+ * Calculate and return the byte length of the smbios entry identified by
+ * dh.  This includes both the formatted portion as well as the
+ * unformatted string space, including the two trailing nul characters.
+ */
+static size_t smbios_entry_length(const struct smbios_header *dh)
+{
+	const char *p = (const char *)dh;
+
+	p += dh->length;
+
+	while (p[0] || p[1])
+		p++;
+
+	return 2 + p - (const char *)dh;
+}
+
+/*************************************************
+ * Support bits for specialized SMBIOS entry support
+ *************************************************/
+struct smbios_entry_attr_show_data {
+	struct attribute *attr;
+	char *buf;
+};
+
+static ssize_t smbios_entry_attr_show_helper(struct smbios_sysfs_entry *entry,
+					     const struct smbios_header *dh,
+					     void *_data)
+{
+	struct smbios_entry_attr_show_data *data = _data;
+	struct smbios_sysfs_mapped_attribute *attr;
+
+	attr = container_of(data->attr,
+			    struct smbios_sysfs_mapped_attribute, attr);
+	return attr->show(entry, dh, data->buf);
+}
+
+static ssize_t smbios_entry_attr_show(struct kobject *kobj,
+				      struct attribute *attr,
+				      char *buf)
+{
+	struct smbios_entry_attr_show_data data = {
+		.attr = attr,
+		.buf  = buf,
+	};
+	/* Find the entry according to our parent and call the
+	 * normalized show method hanging off of the attribute */
+	return find_smbios_entry(to_entry(kobj->parent),
+				 smbios_entry_attr_show_helper, &data);
+}
+
+static const struct sysfs_ops smbios_sysfs_specialize_attr_ops = {
+	.show = smbios_entry_attr_show,
+};
+
+/*************************************************
+ * Specialized SMBIOS entry support.
+ *************************************************/
+
+/*** Type 15 - System Event Table ***/
+
+#define SMBIOS_SEL_ACCESS_METHOD_IO8	0x00
+#define SMBIOS_SEL_ACCESS_METHOD_IO2x8	0x01
+#define SMBIOS_SEL_ACCESS_METHOD_IO16	0x02
+#define SMBIOS_SEL_ACCESS_METHOD_PHYS32	0x03
+#define SMBIOS_SEL_ACCESS_METHOD_GPNV	0x04
+
+struct smbios_system_event_log {
+	struct smbios_header header;
+	u16	area_length;
+	u16	header_start_offset;
+	u16	data_start_offset;
+	u8	access_method;
+	u8	status;
+	u32	change_token;
+	union {
+		struct {
+			u16 index_addr;
+			u16 data_addr;
+		} io;
+		u32	phys_addr32;
+		u16	gpnv_handle;
+		u32	access_method_address;
+	};
+	u8	header_format;
+	u8	type_descriptors_supported_count;
+	u8	per_log_type_descriptor_length;
+	u8	supported_log_type_descriptos[0];
+} __packed;
+
+#define SMBIOS_SYSFS_SEL_FIELD(_field) \
+static ssize_t smbios_sysfs_sel_##_field(struct smbios_sysfs_entry *entry, \
+					 const struct smbios_header *dh, \
+					 char *buf) \
+{ \
+	struct smbios_system_event_log sel; \
+	if (sizeof(sel) > smbios_entry_length(dh)) \
+		return -EIO; \
+	memcpy(&sel, dh, sizeof(sel)); \
+	return sprintf(buf, "%u\n", sel._field); \
+} \
+static SMBIOS_SYSFS_MAPPED_ATTR(sel, _field)
+
+SMBIOS_SYSFS_SEL_FIELD(area_length);
+SMBIOS_SYSFS_SEL_FIELD(header_start_offset);
+SMBIOS_SYSFS_SEL_FIELD(data_start_offset);
+SMBIOS_SYSFS_SEL_FIELD(access_method);
+SMBIOS_SYSFS_SEL_FIELD(status);
+SMBIOS_SYSFS_SEL_FIELD(change_token);
+SMBIOS_SYSFS_SEL_FIELD(access_method_address);
+SMBIOS_SYSFS_SEL_FIELD(header_format);
+SMBIOS_SYSFS_SEL_FIELD(type_descriptors_supported_count);
+SMBIOS_SYSFS_SEL_FIELD(per_log_type_descriptor_length);
+
+static struct attribute *smbios_sysfs_sel_attrs[] = {
+	&smbios_sysfs_attr_sel_area_length.attr,
+	&smbios_sysfs_attr_sel_header_start_offset.attr,
+	&smbios_sysfs_attr_sel_data_start_offset.attr,
+	&smbios_sysfs_attr_sel_access_method.attr,
+	&smbios_sysfs_attr_sel_status.attr,
+	&smbios_sysfs_attr_sel_change_token.attr,
+	&smbios_sysfs_attr_sel_access_method_address.attr,
+	&smbios_sysfs_attr_sel_header_format.attr,
+	&smbios_sysfs_attr_sel_type_descriptors_supported_count.attr,
+	&smbios_sysfs_attr_sel_per_log_type_descriptor_length.attr,
+	NULL,
+};
+
+
+static struct kobj_type smbios_system_event_log_ktype = {
+	.release = smbios_entry_free,
+	.sysfs_ops = &smbios_sysfs_specialize_attr_ops,
+	.default_attrs = smbios_sysfs_sel_attrs,
+};
+
+typedef u8 (*sel_io_reader)(const struct smbios_system_event_log *sel,
+			    loff_t offset);
+
+static DEFINE_MUTEX(io_port_lock);
+
+static u8 read_sel_8bit_indexed_io(const struct smbios_system_event_log *sel,
+				   loff_t offset)
+{
+	u8 ret;
+
+	mutex_lock(&io_port_lock);
+	outb((u8)offset, sel->io.index_addr);
+	ret = inb(sel->io.data_addr);
+	mutex_unlock(&io_port_lock);
+	return ret;
+}
+
+static u8 read_sel_2x8bit_indexed_io(const struct smbios_system_event_log *sel,
+				     loff_t offset)
+{
+	u8 ret;
+
+	mutex_lock(&io_port_lock);
+	outb((u8)offset, sel->io.index_addr);
+	outb((u8)(offset >> 8), sel->io.index_addr + 1);
+	ret = inb(sel->io.data_addr);
+	mutex_unlock(&io_port_lock);
+	return ret;
+}
+
+static u8 read_sel_16bit_indexed_io(const struct smbios_system_event_log *sel,
+				    loff_t offset)
+{
+	u8 ret;
+
+	mutex_lock(&io_port_lock);
+	outw((u16)offset, sel->io.index_addr);
+	ret = inb(sel->io.data_addr);
+	mutex_unlock(&io_port_lock);
+	return ret;
+}
+
+static sel_io_reader sel_io_readers[] = {
+	[SMBIOS_SEL_ACCESS_METHOD_IO8]	= read_sel_8bit_indexed_io,
+	[SMBIOS_SEL_ACCESS_METHOD_IO2x8]	= read_sel_2x8bit_indexed_io,
+	[SMBIOS_SEL_ACCESS_METHOD_IO16]	= read_sel_16bit_indexed_io,
+};
+
+static ssize_t smbios_sel_raw_read_io(struct smbios_sysfs_entry *entry,
+				      const struct smbios_system_event_log *sel,
+				      char *buf, loff_t pos, size_t count)
+{
+	ssize_t wrote = 0;
+
+	sel_io_reader io_reader = sel_io_readers[sel->access_method];
+
+	while (count && pos < sel->area_length) {
+		count--;
+		*(buf++) = io_reader(sel, pos++);
+		wrote++;
+	}
+
+	return wrote;
+}
+
+static ssize_t smbios_sel_raw_read_phys32(struct smbios_sysfs_entry *entry,
+				      const struct smbios_system_event_log *sel,
+					  char *buf, loff_t pos, size_t count)
+{
+	u8 __iomem *mapped;
+	ssize_t wrote = 0;
+
+	mapped = ioremap(sel->access_method_address, sel->area_length);
+	if (!mapped)
+		return -EIO;
+
+	while (count && pos < sel->area_length) {
+		count--;
+		*(buf++) = readb(mapped + pos++);
+		wrote++;
+	}
+
+	iounmap(mapped);
+	return wrote;
+}
+
+static ssize_t smbios_sel_raw_read_helper(struct smbios_sysfs_entry *entry,
+					  const struct smbios_header *dh,
+					  void *_state)
+{
+	struct smbios_read_state *state = _state;
+	struct smbios_system_event_log sel;
+
+	if (sizeof(sel) > smbios_entry_length(dh))
+		return -EIO;
+
+	memcpy(&sel, dh, sizeof(sel));
+
+	switch (sel.access_method) {
+	case SMBIOS_SEL_ACCESS_METHOD_IO8:
+	case SMBIOS_SEL_ACCESS_METHOD_IO2x8:
+	case SMBIOS_SEL_ACCESS_METHOD_IO16:
+		return smbios_sel_raw_read_io(entry, &sel, state->buf,
+					      state->pos, state->count);
+	case SMBIOS_SEL_ACCESS_METHOD_PHYS32:
+		return smbios_sel_raw_read_phys32(entry, &sel, state->buf,
+						  state->pos, state->count);
+	case SMBIOS_SEL_ACCESS_METHOD_GPNV:
+		pr_info("smbios-sysfs: GPNV support missing.\n");
+		return -EIO;
+	default:
+		pr_info("smbios-sysfs: Unknown access method %02x\n",
+			sel.access_method);
+		return -EIO;
+	}
+}
+
+static ssize_t smbios_sel_raw_read(struct file *filp, struct kobject *kobj,
+				   struct bin_attribute *bin_attr,
+				   char *buf, loff_t pos, size_t count)
+{
+	struct smbios_sysfs_entry *entry = to_entry(kobj->parent);
+	struct smbios_read_state state = {
+		.buf = buf,
+		.pos = pos,
+		.count = count,
+	};
+
+	return find_smbios_entry(entry, smbios_sel_raw_read_helper, &state);
+}
+
+static struct bin_attribute smbios_sel_raw_attr = {
+	.attr = {.name = "raw_event_log", .mode = 0400},
+	.read = smbios_sel_raw_read,
+};
+
+static int smbios_system_event_log(struct smbios_sysfs_entry *entry)
+{
+	int ret;
+
+	entry->child = kzalloc(sizeof(*entry->child), GFP_KERNEL);
+	if (!entry->child)
+		return -ENOMEM;
+	ret = kobject_init_and_add(entry->child,
+				   &smbios_system_event_log_ktype,
+				   &entry->kobj,
+				   "system_event_log");
+	if (ret)
+		goto out_free;
+
+	ret = sysfs_create_bin_file(entry->child, &smbios_sel_raw_attr);
+	if (ret)
+		goto out_del;
+
+	return 0;
+
+out_del:
+	kobject_del(entry->child);
+out_free:
+	kfree(entry->child);
+	return ret;
+}
+
+/*************************************************
+ * Generic SMBIOS entry support.
+ *************************************************/
+
+static ssize_t smbios_sysfs_entry_length(struct smbios_sysfs_entry *entry,
+					 char *buf)
+{
+	return sprintf(buf, "%d\n", entry->dh.length);
+}
+
+static ssize_t smbios_sysfs_entry_handle(struct smbios_sysfs_entry *entry,
+					 char *buf)
+{
+	return sprintf(buf, "%d\n", entry->dh.handle);
+}
+
+static ssize_t smbios_sysfs_entry_type(struct smbios_sysfs_entry *entry,
+				       char *buf)
+{
+	return sprintf(buf, "%d\n", entry->dh.type);
+}
+
+static ssize_t smbios_sysfs_entry_instance(struct smbios_sysfs_entry *entry,
+					   char *buf)
+{
+	return sprintf(buf, "%d\n", entry->instance);
+}
+
+static ssize_t smbios_sysfs_entry_position(struct smbios_sysfs_entry *entry,
+					   char *buf)
+{
+	return sprintf(buf, "%d\n", entry->position);
+}
+
+static SMBIOS_SYSFS_ATTR(entry, length);
+static SMBIOS_SYSFS_ATTR(entry, handle);
+static SMBIOS_SYSFS_ATTR(entry, type);
+static SMBIOS_SYSFS_ATTR(entry, instance);
+static SMBIOS_SYSFS_ATTR(entry, position);
+
+static struct attribute *smbios_sysfs_entry_attrs[] = {
+	&smbios_sysfs_attr_entry_length.attr,
+	&smbios_sysfs_attr_entry_handle.attr,
+	&smbios_sysfs_attr_entry_type.attr,
+	&smbios_sysfs_attr_entry_instance.attr,
+	&smbios_sysfs_attr_entry_position.attr,
+	NULL,
+};
+
+static ssize_t smbios_entry_raw_read_helper(struct smbios_sysfs_entry *entry,
+					    const struct smbios_header *dh,
+					    void *_state)
+{
+	struct smbios_read_state *state = _state;
+	size_t entry_length;
+
+	entry_length = smbios_entry_length(dh);
+
+	return memory_read_from_buffer(state->buf, state->count,
+				       &state->pos, dh, entry_length);
+}
+
+static ssize_t smbios_entry_raw_read(struct file *filp,
+				     struct kobject *kobj,
+				     struct bin_attribute *bin_attr,
+				     char *buf, loff_t pos, size_t count)
+{
+	struct smbios_sysfs_entry *entry = to_entry(kobj);
+	struct smbios_read_state state = {
+		.buf = buf,
+		.pos = pos,
+		.count = count,
+	};
+
+	return find_smbios_entry(entry, smbios_entry_raw_read_helper, &state);
+}
+
+static const struct bin_attribute smbios_entry_raw_attr = {
+	.attr = {.name = "raw", .mode = 0400},
+	.read = smbios_entry_raw_read,
+};
+
+static void smbios_sysfs_entry_release(struct kobject *kobj)
+{
+	struct smbios_sysfs_entry *entry = to_entry(kobj);
+	sysfs_remove_bin_file(&entry->kobj, &smbios_entry_raw_attr);
+	spin_lock(&entry_list_lock);
+	list_del(&entry->list);
+	spin_unlock(&entry_list_lock);
+	kfree(entry);
+}
+
+static struct kobj_type smbios_sysfs_entry_ktype = {
+	.release = smbios_sysfs_entry_release,
+	.sysfs_ops = &smbios_sysfs_attr_ops,
+	.default_attrs = smbios_sysfs_entry_attrs,
+};
+
+static struct kobject *smbios_kobj;
+static struct kset *smbios_kset;
+
+/* Global count of all instances seen.  Only for setup */
+static int __initdata instance_counts[MAX_ENTRY_TYPE + 1];
+
+/* Global positional count of all entries seen.  Only for setup */
+static int __initdata position_count;
+
+static int __init smbios_sysfs_register_handle(const union smbios_struct *ss,
+					       void *_ret)
+{
+	struct smbios_sysfs_entry *entry;
+	int *ret = _ret;
+
+	/* Allocate and register a new entry into the entries set */
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry) {
+		*ret = -ENOMEM;
+		return SMBIOS_WALK_STOP;
+	}
+
+	/* Set the key */
+	memcpy(&entry->dh, &ss->header, sizeof(struct smbios_header));
+	entry->instance = instance_counts[ss->header.type]++;
+	entry->position = position_count++;
+
+	entry->kobj.kset = smbios_kset;
+	*ret = kobject_init_and_add(&entry->kobj, &smbios_sysfs_entry_ktype,
+				    NULL,
+				    "%d-%d", ss->header.type, entry->instance);
+
+	if (*ret) {
+		kfree(entry);
+		return SMBIOS_WALK_STOP;
+	}
+
+	/* Thread on the global list for cleanup */
+	spin_lock(&entry_list_lock);
+	list_add_tail(&entry->list, &entry_list);
+	spin_unlock(&entry_list_lock);
+
+	/* Handle specializations by type */
+	switch (ss->header.type) {
+	case 15:
+		/* System Event Log */
+		*ret = smbios_system_event_log(entry);
+		break;
+	default:
+		/* No specialization */
+		break;
+	}
+	if (*ret)
+		goto out_err;
+
+	/* Create the raw binary file to access the entry */
+	*ret = sysfs_create_bin_file(&entry->kobj, &smbios_entry_raw_attr);
+	if (*ret)
+		goto out_err;
+
+	return SMBIOS_WALK_CONTINUE;
+out_err:
+	kobject_put(entry->child);
+	kobject_put(&entry->kobj);
+	return SMBIOS_WALK_STOP;
+}
+
+static void cleanup_entry_list(void)
+{
+	struct smbios_sysfs_entry *entry, *next;
+
+	/* No locks, we are on our way out */
+	list_for_each_entry_safe(entry, next, &entry_list, list) {
+		kobject_put(entry->child);
+		kobject_put(&entry->kobj);
+	}
+}
+
+static int __init smbios_sysfs_init(void)
+{
+	int error = -ENOMEM;
+	int val, ret;
+	const union smbios_struct *ss;
+
+	/* Set up our directory */
+	smbios_kobj = kobject_create_and_add("smbios", firmware_kobj);
+	if (!smbios_kobj)
+		goto err;
+
+	smbios_kset = kset_create_and_add("entries", NULL, smbios_kobj);
+	if (!smbios_kset)
+		goto err;
+
+	val = 0;
+	ss = smbios_walk(smbios_sysfs_register_handle, &val);
+	if (ss) {
+		error = -EIO;
+		goto err;
+	}
+	if (val) {
+		error = val;
+		goto err;
+	}
+
+#ifdef CONFIG_SYSTEM_FIRMWARE_DMI_COMPAT
+	ret = sysfs_create_link(firmware_kobj, smbios_kobj, "dmi");
+	if (!ret)
+		pr_debug("smbios-sysfs: DMI compatibility failed.\n");
+#endif
+	pr_debug("smbios-sysfs: loaded.\n");
+
+	return 0;
+err:
+	cleanup_entry_list();
+	kset_unregister(smbios_kset);
+	kobject_put(smbios_kobj);
+	return error;
+}
+
+/* clean up everything. */
+static void __exit smbios_sysfs_exit(void)
+{
+	pr_debug("smbios-sysfs: unloading.\n");
+	cleanup_entry_list();
+	kset_unregister(smbios_kset);
+	kobject_put(smbios_kobj);
+}
+
+module_init(smbios_sysfs_init);
+module_exit(smbios_sysfs_exit);
+
+MODULE_AUTHOR("Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>");
+MODULE_DESCRIPTION("SMBIOS sysfs support");
+MODULE_LICENSE("GPL");
diff --git a/drivers/firmware/smbios.c b/drivers/firmware/smbios.c
new file mode 100644
index 0000000..ff83ae5
--- /dev/null
+++ b/drivers/firmware/smbios.c
@@ -0,0 +1,687 @@
+/*
+ * SMBIOS support
+ *
+ * started by Prarit Bhargava, Copyright (C) 2011 Red Hat, Inc.
+ *
+ * SMBIOS interpretation
+ *
+ * Some bits copied directly from original dmi*.c files
+ */
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/ctype.h>
+#include <linux/smbios.h>
+#include <linux/efi.h>
+#include <linux/bootmem.h>
+#include <linux/sysfw.h>
+#include <linux/pci.h>
+
+#include <asm/smbios.h>
+
+/*
+ * "The SMBIOS Specification addresses how motherboard and system vendors
+ * present management information about their products in a standard format by
+ * extending the BIOS interface on x86 architecture systems. The information is
+ * intended to allow generic instrumentation to deliver this information to
+ * management applications that use DMI, CIM or direct access, eliminating the
+ * need for error prone operations like probing system hardware for presence
+ * detection."
+ *
+ * From http://www.dmtf.org/standards/smbios
+ *
+ * ... Grab the Spec.  It'll help.
+ */
+
+/*
+ * SMBIOS Structure Table Entry Point, STEP
+ */
+struct smbios_step {
+	char	anchor_string[4];	/* 0x0, always is "_SM_" */
+	u8	checksum;
+	u8	length;
+	u8	major;
+	u8	minor;
+	u16	max_size;
+	u8	eps_revision;
+	u8	reserved[5];
+	u8	dmi_string[5];		/* 0x10, always is "_DMI_" */
+	u8	intermediate_chksum;
+	u16	struct_len;
+	u32	struct_addr;
+	u16	num_structs;
+	u8	bcd_revision;
+} __packed;
+static struct smbios_step smbios_step;
+
+/* is there an SMBIOS? */
+int smbios_available;
+EXPORT_SYMBOL_GPL(smbios_available);
+
+/* Address of the actual SMBIOS struct */
+static unsigned long smbios_addr;
+
+/* Start address of the SMBIOS tables */
+static u32 smbios_base;
+/* Length of the all the SMBIOS tables */
+static u16 smbios_len;
+/* Number of SMBIOS tables */
+static u16 smbios_num;
+/*
+ * This is the BRK space or IO mapped address of the SMBIOS table.  SMBIOS is
+ * switched from BRK space and into the IO map in smbios_init_late().  After
+ * it is IO mapped, it MUST NOT be unmapped (o/w very bad things will happen).
+ */
+static u8 *smbios_map;
+
+/* We need to store the type field and the UUID somewhere. */
+static char smbios_type3_type[4];
+static char smbios_type1_uuid[16*2+4+1];
+
+/** find the first SMBIOS structure of a specific type */
+const union smbios_struct *smbios_find_struct(int type)
+{
+	int size = sizeof(struct smbios_header);
+	int i = 0;
+	u8 *data = smbios_map;
+	struct smbios_header *dm = NULL;
+
+	/*
+	 *	Stop when we see all the items the table claimed to have
+	 *	OR we run off the end of the table (also happens)
+	 */
+	while ((i < smbios_num) &&
+	       (data - smbios_map + size) <= smbios_len) {
+		dm = (struct smbios_header *)data;
+
+		/*
+		 *  We want to know the total length (formatted area and
+		 *  strings) before returning to make sure we don't return
+		 *  a partial structure
+		 */
+		data += dm->length;
+		while ((data - smbios_map < smbios_len - 1) &&
+		       (data[0] || data[1]))
+			data++;
+		if ((data - smbios_map < smbios_len - 1) &&
+		    (type == dm->type)) {
+			break;
+		}
+		data += 2;
+		i++;
+	}
+	/* just return the address */
+	return (const union smbios_struct *)dm;
+}
+
+static const char smbios_empty_string[] = "        ";
+
+/**
+ * smbios_get_string -- return a string from an SMBIOS structure
+ * @ss: pointer to structure being examined
+ * @s: number of string being examined
+ *
+ * This function returns a string within the structure ss.  Many SMBIOS
+ * structures have their strings at the end of the structure, and the location
+ * of each string is enumerated throughout the structure.
+ *
+ * For example,  The BIOS Information structure, type0, has the BIOS Version
+ * at offset 0x6, which contains a number enumerating the strings at the end
+ * of the structure.
+ *
+ * ie) s is an actual _number_, not a pointer.
+ */
+const char *smbios_get_string(const union smbios_struct *ss, u8 s)
+{
+	const u8 *bp = ((u8 *) ss) + ss->header.length;
+
+	if (s) {
+		s--;
+		while (s > 0 && *bp) {
+			bp += strlen(bp) + 1;
+			s--;
+		}
+
+		if (*bp != 0) {
+			size_t len = strlen(bp)+1;
+			size_t cmp_len = len > 8 ? 8 : len;
+
+			if (!memcmp(bp, smbios_empty_string, cmp_len))
+				return smbios_empty_string;
+			return bp;
+		}
+	}
+
+	return "";
+}
+EXPORT_SYMBOL(smbios_get_string);
+
+#define smbios_find_ptr(_ptr, _struct_name, _type, _field)		 \
+	_struct_name = smbios_find_struct(_type);			 \
+	_ptr = smbios_get_string(_struct_name,				 \
+				 _struct_name->type##_type._field);
+
+static const char *smbios_sysfw_lookup(int field)
+{
+	const union smbios_struct *ss;
+	const u8 *ptr;
+
+	switch (field) {
+	case SYSFW_BIOS_VENDOR:
+		smbios_find_ptr(ptr, ss, 0, vendor);
+		break;
+	case SYSFW_BIOS_VERSION:
+		smbios_find_ptr(ptr, ss, 0, bios_version);
+		break;
+	case SYSFW_BIOS_DATE:
+		smbios_find_ptr(ptr, ss, 0, bios_release_date);
+		break;
+	case SYSFW_SYS_VENDOR:
+		smbios_find_ptr(ptr, ss, 1, manufacturer);
+		break;
+	case SYSFW_PRODUCT_NAME:
+		smbios_find_ptr(ptr, ss, 1, product_name);
+		break;
+	case SYSFW_PRODUCT_VERSION:
+		smbios_find_ptr(ptr, ss, 1, version);
+		break;
+	case SYSFW_PRODUCT_SERIAL:
+		smbios_find_ptr(ptr, ss, 1, serial_number);
+		break;
+	case SYSFW_PRODUCT_UUID:
+		ptr = smbios_type1_uuid;
+		break;
+	case SYSFW_BOARD_VENDOR:
+		smbios_find_ptr(ptr, ss, 2, manufacturer);
+		break;
+	case SYSFW_BOARD_NAME:
+		smbios_find_ptr(ptr, ss, 2, product);
+		break;
+	case SYSFW_BOARD_VERSION:
+		smbios_find_ptr(ptr, ss, 2, version);
+		break;
+	case SYSFW_BOARD_SERIAL:
+		smbios_find_ptr(ptr, ss, 2, serial_number);
+		break;
+	case SYSFW_BOARD_ASSET_TAG:
+		smbios_find_ptr(ptr, ss, 2, asset_tag);
+		break;
+	case SYSFW_CHASSIS_VENDOR:
+		smbios_find_ptr(ptr, ss, 3, manufacturer);
+		break;
+	case SYSFW_CHASSIS_TYPE:
+		ptr = smbios_type3_type;
+		break;
+	case SYSFW_CHASSIS_VERSION:
+		smbios_find_ptr(ptr, ss, 3, version);
+		break;
+	case SYSFW_CHASSIS_SERIAL:
+		smbios_find_ptr(ptr, ss, 3, serial_number);
+		break;
+	case SYSFW_CHASSIS_ASSET_TAG:
+		smbios_find_ptr(ptr, ss, 3, asset_tag_number);
+		break;
+	case SYSFW_STRING_MAX:
+	case SYSFW_NONE:
+	default:
+		ptr = NULL;
+		break;
+	}
+
+	return (const char *)ptr;
+}
+
+/* returns date in formation YYYYMMDD for easy comparisons */
+static int smbios_sysfw_get_date(void)
+{
+	const char *smbios_date;
+	int date, d, m, y;
+
+	/* SMBIOS BIOS DATE is in DD/MM/YYYY format */
+	smbios_date = smbios_sysfw_lookup(SYSFW_BIOS_DATE);
+	if (!smbios_date)
+		return 0;
+
+	sscanf(smbios_date, "%d/%d/%d", &d, &m, &y);
+	date = (y * 10000 + m * 100 + d);
+	return date;
+}
+
+static int __init smbios_sysfw_late(void)
+{
+	if (!smbios_available)
+		return -1;
+
+	/* This looks strange but we're unmapping the BRK space and
+	 * then mapping into memory after the memory subsystem has been
+	 * initialized. */
+	smbios_iounmap(smbios_map, smbios_len);
+	smbios_map = ioremap(smbios_base, smbios_len);
+	if (!smbios_map) {
+		smbios_available = 0;
+		WARN(1, "SMBIOS ioremap failed.");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+/* print pretty things */
+static void __init print_filtered(const char *info)
+{
+	const char *p;
+
+	if (!info)
+		return;
+
+	for (p = info; *p; p++)
+		if (isprint(*p))
+			printk(KERN_CONT "%c", *p);
+		else
+			printk(KERN_CONT "\\x%02x", *p & 0xff);
+}
+
+/* Dump some basic system information at the beginning of boot */
+static void __init smbios_boot_display(void)
+{
+	const char *board;	/* Board Name is optional */
+
+	if (smbios_available)
+		printk(KERN_DEBUG "SMBIOS: ");
+	else
+		printk(KERN_DEBUG "DMI: ");
+	print_filtered(smbios_sysfw_lookup(SYSFW_SYS_VENDOR));
+	printk(KERN_CONT " ");
+	print_filtered(smbios_sysfw_lookup(SYSFW_PRODUCT_NAME));
+	board = smbios_sysfw_lookup(SYSFW_BOARD_NAME);
+	if (board) {
+		printk(KERN_CONT "/");
+		print_filtered(board);
+	}
+	printk(KERN_CONT ", BIOS ");
+	print_filtered(smbios_sysfw_lookup(SYSFW_BIOS_VERSION));
+	printk(KERN_CONT " ");
+	print_filtered(smbios_sysfw_lookup(SYSFW_BIOS_DATE));
+	printk(KERN_CONT "\n");
+}
+
+static int __init smbios_sysfw_init(void)
+{
+	smbios_boot_display();
+	printk(KERN_INFO "Registered SMBIOS sysfw driver\n");
+	return 0;
+}
+
+static struct sysfw_driver __refdata smbios_sysfw_driver = {
+	.name = "smbios",
+	.init = smbios_sysfw_init,
+	.late = smbios_sysfw_late,
+	.lookup = smbios_sysfw_lookup,
+	.date = smbios_sysfw_get_date,
+};
+
+/*
+ * There are two special "core" values, that require their own strings.
+ * These are SYSFW_CHASSIS_TYPE(ss->type3->type) and
+ * SYSFW_PRODUCT_UUID(ss->type1->uuid).
+ */
+static void smbios_decode_core(void)
+{
+	const union smbios_struct *ss;
+
+	/* SYSFW_CHASSIS_TYPE */
+	ss = smbios_find_struct(3);
+	sprintf(smbios_type3_type, "%u", ss->type3.type & 0x7f);
+	/* SYSFW_PRODUCT_UUID */
+	ss = smbios_find_struct(1);
+	sprintf(smbios_type1_uuid, "%pUB", ss->type1.uuid);
+}
+
+/* This is only useful for legacy DMI table decoding. */
+static int __init dmi_checksum(const u8 *buf)
+{
+	u8 sum = 0;
+	int a;
+
+	for (a = 0; a < 15; a++)
+		sum += buf[a];
+
+	return sum == 0;
+}
+
+/* This is only useful for legacy DMI table decoding. */
+static int __init dmi_present(const char __iomem *p)
+{
+	u8 buf[15];
+
+	memcpy_fromio(buf, p, 15);
+	if ((memcmp(buf, "_DMI_", 5) == 0) && dmi_checksum(buf)) {
+		/* use smbios_ even though it's really dmi_ */
+		smbios_num = (buf[13] << 8) | buf[12];
+		smbios_len = (buf[7] << 8) | buf[6];
+		smbios_base = (buf[11] << 24) | (buf[10] << 16) |
+			(buf[9] << 8) | buf[8];
+
+		printk(KERN_INFO "DMI %d.%d present.\n", buf[14] >> 4,
+		       buf[14] & 0xF);
+
+		smbios_map = smbios_ioremap(smbios_base, smbios_len);
+		if (!smbios_map)
+			return -ENOMEM;
+		smbios_boot_display();
+	}
+	return 1;
+}
+
+/* Check and decode the SMBIOS STEP function */
+static int __init smbios_decode_step(void)
+{
+	u8 chksum1, chksum2, *buf, fp;
+
+	if (!smbios_addr)
+		return -ENODEV;
+
+	buf = smbios_ioremap(smbios_addr, sizeof(struct smbios_step));
+	if (!buf)
+		return -ENODEV;
+
+	memcpy(&smbios_step, buf, sizeof(struct smbios_step));
+
+	/* checksum the entire STEP structure */
+	chksum1 = 0;
+	for (fp = 0; fp < smbios_step.length; fp++)
+		chksum1 += buf[fp];
+	if (chksum1) {
+		smbios_iounmap(buf, sizeof(struct smbios_step));
+		WARN(1, "SMBIOS: Invalid STEP table checksum = %u\n", chksum1);
+		return -EINVAL;
+	}
+
+	/* checksum the Intermediate structure */
+	chksum2 = 0;
+	for (fp = 0x10; fp < smbios_step.length; fp++)
+		chksum2 += buf[fp];
+	if (chksum2) {
+		smbios_iounmap(buf, sizeof(struct smbios_step));
+		WARN(1, "SMBIOS: Invalid Intermediate checksum = %u\n",
+		     chksum2);
+		return -EINVAL;
+	}
+
+	smbios_iounmap(buf, sizeof(struct smbios_step));
+
+	printk(KERN_INFO "SMBIOS: version %u.%u @ 0x%lX | %d structures\n",
+	       smbios_step.major, smbios_step.minor, smbios_addr,
+	       smbios_step.num_structs);
+
+	smbios_num = smbios_step.num_structs;
+	smbios_len = smbios_step.struct_len;
+	smbios_base = smbios_step.struct_addr;
+
+	/*
+	 * Need to map smbios_map for the smbios_walk() and other potential
+	 * early callers.  This is unmapped, and ioremap'ed in the late call.
+	 */
+	smbios_map = smbios_ioremap(smbios_base, smbios_len);
+	if (!smbios_map) {
+		printk(KERN_INFO "SMBIOS tables are invalid.\n");
+		return -ENOMEM;
+	}
+	smbios_available = 1;
+
+	return 0;
+}
+
+/**
+ * smbios_init - Initialize the SMBIOS code and register a sysfw driver
+ *
+ * This function looks for the SMBIOS tables, maps them, and registers a
+ * System Firmware driver.
+ */
+int __init smbios_init(void)
+{
+	u8 *buf;
+	int fp = 0, rc;
+	int ret = 0;
+	int smbios_present = 0;
+
+	if (efi_enabled) {
+		if (efi.smbios == EFI_INVALID_TABLE_ADDR) {
+			ret = -ENODEV;
+			goto error;
+		}
+		smbios_addr = efi.smbios;
+	} else {
+		/*
+		 * Legacy SMBIOS is mapped @ 0xF0000, but may not
+		 * necessarily be _at_ 0xF0000
+		 */
+		smbios_addr = 0xF0000;
+	}
+	buf = smbios_ioremap(smbios_addr, SMBIOS_SIZE);
+	if (!buf) {
+		ret = -ENODEV;
+		goto error;
+	}
+
+	/* Find the SMBIOS entry point */
+	for (fp = 0; fp <= 0xFFF0; fp += 0x10) {
+		if (!memcmp(buf + fp, "_SM_", 4)) {
+			smbios_addr += fp;
+			smbios_present = 1;
+			break;
+		}
+	}
+	smbios_iounmap(buf, SMBIOS_SIZE);
+
+	if (smbios_present) {
+		rc = smbios_decode_step();
+		if (rc)
+			return -ENODEV;
+		rc = sysfw_driver_register(&smbios_sysfw_driver);
+		if (rc)
+			return rc;
+		smbios_decode_core();
+	} else {
+		/*
+		 * SMBIOS has been around since the 1990s.  The likelihood
+		 * of there being a DMI table not embedded in a SMBIOS table
+		 * is extremely unlikely, but the old code did look for this
+		 * and there is at least a possibility of a system out there
+		 * like this ... so check to see if an old legacy _DMI_ table
+		 * is available.
+		 *
+		 * XXX: Hopefully we can get rid of this one day.
+		 */
+		buf = smbios_ioremap(smbios_addr, SMBIOS_SIZE);
+		if (!buf) {
+			ret = -ENODEV;
+			goto error;
+		}
+
+		/* Find the DMI entry point */
+		for (fp = 0; fp <= 0xFFF0; fp += 0x10) {
+			if (dmi_present(buf + fp)) {
+				smbios_addr += fp;
+				break;
+			}
+		}
+		smbios_iounmap(buf, SMBIOS_SIZE);
+	}
+error:
+	if (!smbios_present)
+		printk(KERN_INFO "SMBIOS not present.");
+	return ret;
+
+}
+
+/**
+ * smbios_walk - executes a function for each SMBIOS structure
+ * @decode: Function to execute
+ * private_data: data passed into decode function
+ *
+ * This function walks the SMBIOS structures and executes decode on each
+ * structure.  This should have minimal usage in the kernel.  Unless you have
+ * need to access the raw SMBIOS data, you should use sysfw_lookup() or
+ * sysfw_callback().
+ */
+const union smbios_struct
+*smbios_walk(int (*decode)(const union smbios_struct *, void *),
+			   void *private_data)
+{
+	u8 *data = smbios_map;
+	int size = sizeof(struct smbios_header);
+	int i = 0;
+	int ret = SMBIOS_WALK_CONTINUE;
+	const union smbios_struct *ss = NULL;
+
+	/*
+	 * Stop when we see all the items the table claimed to have
+	 * OR we run off the end of the table (also happens)
+	 */
+	while ((i < smbios_num) &&
+	       (data - smbios_map + size) <= smbios_len) {
+		const struct smbios_header *dm;
+
+		/*
+		 *  We want to know the total length (formatted area and
+		 *  strings) before decoding to make sure we won't run off the
+		 *  table
+		 */
+		dm = (const struct smbios_header *)data;
+		data += dm->length;
+		while ((data - smbios_map < smbios_len - 1) &&
+		       (data[0] || data[1]))
+			data++;
+		if (data - smbios_map < smbios_len - 1) {
+			ret = decode((union smbios_struct *)dm, private_data);
+			if (ret == SMBIOS_WALK_STOP) {
+				ss = (union smbios_struct *)dm;
+				break;
+			}
+		}
+		data += 2;
+		i++;
+	}
+
+	return ss;
+}
+EXPORT_SYMBOL_GPL(smbios_walk);
+
+/*
+ * Helper Functions -- We really don't want a lot of these, but structs like
+ * the OEM Strings have a lot of elements and multiple drivers need to
+ * grep through them for string matches.  Might as well do all of this in
+ * one place.
+ */
+
+/*
+ * This seems really general and currently has only two specific needs
+ * in the kernel (type10 and type11).  But looking at other structs we'll need
+ * this for those as well.
+ */
+struct _smbios_strings {
+	int type;
+	int (*count_fn)(const union smbios_struct *ss);
+	const char *in;
+	const char *out;
+};
+
+/* returns SMBIOS_WALK_STOP & match->out != NULL on string match success */
+static int _match_string(const union smbios_struct *ss, void *_match)
+{
+	int i;
+	const char *str;
+	struct _smbios_strings *match = (struct _smbios_strings *)_match;
+
+	if (ss->header.type != match->type)
+		return SMBIOS_WALK_CONTINUE;
+
+	BUG_ON(!match->count_fn);
+
+	for (i = 1; i <= match->count_fn(ss); i++) {
+		str = smbios_get_string(ss, i);
+		if (!strncmp(match->in, str, strlen(match->in))) {
+			match->out = str;
+			return SMBIOS_WALK_STOP;
+		}
+	}
+
+	return SMBIOS_WALK_CONTINUE;
+}
+
+static int type10_count_fn(const union smbios_struct *ss)
+{
+	/*
+	 * From SMBIOS Specification: The user of this structure determines the
+	 * the number of devices as (Length - 4)/2.
+	 */
+	return (ss->header.length - 4) / 2;
+}
+
+const char *smbios_match_type10_string(const char *match, int check_disabled)
+{
+	struct _smbios_strings _match = {
+		.in = match,
+		.out = NULL,
+		.type = 10,
+		.count_fn = type10_count_fn,
+	};
+	const union smbios_struct *ss;
+
+	ss = smbios_walk(_match_string, (void *)&_match);
+	if ((ss && check_disabled) || (ss && (ss->type10.device_type & 0x80)))
+		return _match.out;
+	return NULL;
+}
+
+/** smbios_is_onboard_device - Determines if a device is on (soldered on)
+ * @match: string to match
+ * @check_disabled_devices: match against devices marked disabled in structure
+ *
+ * This function returns true if the string passed in matches a device
+ * that the SMBIOS recognizes as being on board (soldered on).  The function
+ * also can ignore SMBIOS's information about whether or not a device is
+ * disabled in order to workaround broken BIOSes.
+ *
+ * Note: This currently only looks at the type 10 structure.
+ */
+bool smbios_is_onboard_device(const char *match, int check_disabled_devices)
+{
+	const char *ret;
+
+	ret = smbios_match_type10_string(match, check_disabled_devices);
+	if (ret)
+		return true;
+	return false;
+}
+EXPORT_SYMBOL_GPL(smbios_is_onboard_device);
+
+static int type11_count_fn(const union smbios_struct *ss)
+{
+	return ss->type11.count;
+}
+
+/**
+ * smbios_match_oem_string - match a string with the OEM strings provided by
+ * @match: string to match
+ *
+ * This function returns the matching SMBIOS string if the string passed in
+ * matches the OEM strings provided by the SMBIOS.
+ */
+const char *smbios_match_oem_string(const char *match)
+{
+	struct _smbios_strings _match = {
+		.in = match,
+		.out = NULL,
+		.type = 11,
+		.count_fn = type11_count_fn,
+	};
+	const union smbios_struct *ss;
+
+	ss = smbios_walk(_match_string, (void *)&_match);
+	if (ss)
+		return _match.out;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(smbios_match_oem_string);
diff --git a/include/linux/smbios.h b/include/linux/smbios.h
new file mode 100644
index 0000000..180a5d8
--- /dev/null
+++ b/include/linux/smbios.h
@@ -0,0 +1,243 @@
+/*
+ * linux/include/smbios.h
+ *
+ * "The SMBIOS Specification addresses how motherboard and system vendors
+ * present management information about their products in a standard format by
+ * extending the BIOS interface on x86 architecture systems. The information is
+ * intended to allow generic instrumentation to deliver this information to
+ * management applications that use DMI, CIM or direct access, eliminating the
+ * need for error prone operations like probing system hardware for presence
+ * detection."
+ *
+ * From http://www.dmtf.org/standards/smbios
+ *
+ * ... Grab the Spec.  It'll help.
+ */
+#ifndef __SMBIOS_H__
+#define __SMBIOS_H__
+
+#include <linux/mod_devicetable.h>
+
+/* struct smbios_step (SMBIOS STEP) is defined in drivers/firmware/smbios.c */
+/* enum sysfw_field (SYSFW_BIOS_VENDOR, etc.) is in mod_devicetable.h */
+
+/* max size of SMBIOS as specified in SMBIOS Specification */
+#define SMBIOS_SIZE 0x10000
+
+struct smbios_header {
+	u8 type;
+	u8 length;
+	u16 handle;
+} __attribute__((__packed__));
+
+/* UNION of SMBIOS types as listed in SMBIOS Specification. */
+union smbios_struct {
+	struct smbios_header header;
+	struct { /* BIOS Information */
+		struct smbios_header header;
+		u8 vendor;
+		u8 bios_version;
+		u16 bios_starting_address_segment;
+		u8 bios_release_date;
+		u8 bios_rom_size;
+		u32 bios_characteristics;
+		u16 bios_characteristics_extension_bytes;
+		u8 system_bios_major_release;
+		u8 system_bios_minor_release;
+		u8 embedded_controller_firmware_major_release;
+		u8 embedded_controller_firmware_minor_release;
+	} __attribute__((__packed__)) type0;
+	struct { /* System Information */
+		struct smbios_header header;
+		u8 manufacturer;
+		u8 product_name;
+		u8 version;
+		u8 serial_number;
+		u8 uuid[16];
+		u8 wake_up_type;
+		u8 sku_number;
+	} __attribute__((__packed__)) type1;
+	struct { /* Baseboard (or Module) Information */
+		struct smbios_header header;
+		u8 manufacturer;
+		u8 product;
+		u8 version;
+		u8 serial_number;
+		u8 asset_tag;
+		u8 feature_flags;
+	} __attribute__((__packed__)) type2;
+	struct { /* System Enclosure of Chassis */
+		struct smbios_header header;
+		u8 manufacturer;
+		u8 type;
+		u8 version;
+		u8 serial_number;
+		u8 asset_tag_number;
+		u8 boot_up_state;
+		u8 power_supply_state;
+		u8 thermal_state;
+		u8 security_status;
+		u8 oem_defined;
+		u8 height;
+		u8 number_of_power_cords;
+		u8 contained_element_count;
+		u8 contained_element_record;
+		/* contained elements = contained_element_count X */
+		/*			contained_element_record  */
+		u8 contained_elements;
+		/* u8 sku_number is allocated after that	  */
+	} __attribute__((__packed__)) type3;
+	struct { /* System Slots */
+		struct smbios_header header;
+		u8 slot_designation;
+		u8 slot_type;
+		u8 slot_data_bus_width;
+		u8 current_usage;
+		u8 slot_length;
+		u16 slot_id;
+		u8 slot_characteristics_1;
+		u8 slot_characteristics_2;
+		u16 segment_group_number;
+		u8 bus_number;
+		u8 device_function_number;
+	} __attribute__((__packed__)) type9;
+	struct { /* On Board Devices Information (Obsolete) */
+		struct smbios_header header;	/* count = (length - 4)/2 */
+		u8 device_type;			/* one for each device */
+		/* strings at end of struct, one per device */
+	} __attribute__((__packed__)) type10;
+	struct { /* OEM Strings */
+		struct smbios_header header;
+		u8 count;
+		u8 start;
+		/* variable number (equal to count) strings listed here */
+	} __attribute__((__packed__)) type11;
+	struct { /* IPMI Device Information - BMC Interface Type */
+		struct smbios_header header;
+		u8 interface_type;
+		u8 ipmi_specification_revision;
+		u8 i2c_slave_address;
+		u8 nv_storage_device_address;
+		u32 base_address;
+		union {
+			u8 base_address_modifier;
+			u8 interrupt_info;
+		};
+		u8 interrupt_number;
+	} __attribute__((__packed__)) type38;
+	struct { /* Onboard Devices Extended Information */
+		struct smbios_header header;
+		u8 reference_designation; /* "silkscreen label */
+		u8 device_type;
+		u8 device_type_instance;
+		u16 segment_group_number;
+		u8 bus_number;
+		u8 device_function_number;
+	} __attribute__((__packed__)) type41;
+};
+
+/* enum used for returns in smbios_walk decode() function */
+enum smbios_walk_value {
+	SMBIOS_WALK_CONTINUE = 0,	/* continue executing in smbios_walk */
+	SMBIOS_WALK_STOP,		/* stop executing and return */
+};
+
+#ifdef CONFIG_SMBIOS
+
+/* is there an SMBIOS on this system? */
+extern int smbios_available;
+
+/**
+ * smbios_get_string -- return a string from an SMBIOS structure
+ * @ss: pointer to structure being examined
+ * @s: number of string being examined
+ *
+ * This function returns a string within the structure ss.  Many SMBIOS
+ * structures have their strings at the end of the structure, and the location
+ * of each string is enumerated throughout the structure.
+ *
+ * For example,  The BIOS Information structure, type0, has the BIOS Version
+ * at offset 0x6, which contains a number enumerating the strings at the end
+ * of the structure.
+ *
+ * ie) s is an actual _number_, not a pointer.
+ */
+extern const char *smbios_get_string(const union smbios_struct *ss, u8 s);
+
+/**
+ * smbios_init - Initialize the SMBIOS code and register a sysfw driver
+ *
+ * This function looks for the SMBIOS tables, maps them, and registers a
+ * System Firmware driver.
+ */
+extern int smbios_init(void);
+
+/**
+ * smbios_walk - executes a function for each SMBIOS structure
+ * @decode: Function to execute
+ * private_data: data passed into decode function
+ *
+ * This function walks the SMBIOS structures and executes decode on each
+ * structure.  If you are looking for a specific unique type of structure,
+ * you should use smbios_find_struct().
+ *
+ * This should have minimal usage in the kernel.  The only reason this should
+ * be used is if you need access the raw SMBIOS data.  Otherwise you should
+ * use sysfw_lookup() or sysfw_callback().
+ */
+extern const union smbios_struct *
+smbios_walk(int (*decode)(const union smbios_struct *, void *),
+	    void *private_data);
+
+/* Helper Functions */
+
+/** smbios_is_onboard_device - Determines if a device is on (soldered on)
+ * @match: string to match
+ * @check_disabled_devices: match against devices marked disabled in structure
+ *
+ * This function returns true if the string passed in matches a device
+ * that the SMBIOS recognizes as being on board (soldered on).  The function
+ * also can ignore SMBIOS's information about whether or not a device is
+ * disabled in order to workaround broken BIOSes.
+ *
+ * XXX: Fix me.  This currently only looks at the type 10 structure.
+ */
+extern bool smbios_is_onboard_device(const char *match,
+				     int check_disabled_devices);
+
+/**
+ * smbios_match_oem_string - match a string with the OEM strings provided by
+ * @match: string to match
+ *
+ * This function returns the matching SMBIOS string if the string passed in
+ * matches the OEM strings provided by the SMBIOS.
+ */
+extern const char *smbios_match_oem_string(const char *match);
+
+#else
+#define smbios_available 0
+static inline const char *smbios_get_string(const union smbios_struct *ss, u8 s)
+{
+	return NULL;
+}
+static inline void smbios_init(void)
+{
+	return;
+}
+static inline const union smbios_struct
+*smbios_walk(int (*decode)(const union smbios_struct *, void *),
+	     void *private_data)
+{
+	return NULL;
+}
+static inline bool smbios_is_onboard_device(const char *match,
+					    int check_disabled_devices)
+{
+	return 0;
+}
+static inline const char *smbios_match_oem_string(const char *match)
+{
+	return NULL;
+}
+#endif
+#endif	/* __SMBIOS_H__ */
-- 
1.6.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
