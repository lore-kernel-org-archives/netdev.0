From: Stefan Achatz <erazor_de@users.sourceforge.net>
Subject: [PATCH 5/5] HID: roccat: Add support for Roccat Kone[+] v2
Date: Fri, 26 Nov 2010 20:57:42 +0100
Message-ID: <1290801462.18750.166.camel__16994.3889290609$1290801524$gmane$org@neuromancer>
Reply-To: erazor_de@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@xenotime.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	linux-doc@vger.kernel.org, l
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-17.arcor-online.net ([151.189.21.57]:47048 "EHLO
	mail-in-17.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843Ab0KZT5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 14:57:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for Roccat Kone[+] gaming mouse. Kone[+] is an enhanced version
of the old Kone with more memory for macros, a better sensor and more functionality.
This driver is conceptual similar to the existing Kone and Pyra drivers.
Userland tools can soon be found at http://sourceforge.net/projects/roccat

Signed-off-by: Stefan Achatz <erazor_de@users.sourceforge.net>
---
 .../ABI/testing/sysfs-driver-hid-roccat-koneplus   |  108 +++
 drivers/hid/Kconfig                                |    7 +
 drivers/hid/Makefile                               |    1 +
 drivers/hid/hid-core.c                             |    1 +
 drivers/hid/hid-ids.h                              |    1 +
 drivers/hid/hid-roccat-koneplus.c                  |  837 ++++++++++++++++++++
 drivers/hid/hid-roccat-koneplus.h                  |  232 ++++++
 7 files changed, 1187 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-driver-hid-roccat-koneplus
 create mode 100644 drivers/hid/hid-roccat-koneplus.c
 create mode 100644 drivers/hid/hid-roccat-koneplus.h

diff --git a/Documentation/ABI/testing/sysfs-driver-hid-roccat-koneplus b/Documentation/ABI/testing/sysfs-driver-hid-roccat-koneplus
new file mode 100644
index 0000000..0ebb640
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-driver-hid-roccat-koneplus
@@ -0,0 +1,108 @@
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/actual_profile
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	When read, this file returns the number of the actual profile in
+		range 0-4.
+		This file is readonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/firmware_version
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	When read, this file returns the raw integer version number of the
+		firmware reported by the mouse. Using the integer value eases
+		further usage in other programs. To receive the real version
+		number the decimal point has to be shifted 2 positions to the
+		left. E.g. a returned value of 121 means 1.21
+		This file is readonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/macro
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The mouse can store a macro with max 500 key/button strokes
+		internally.
+		When written, this file lets one set the sequence for a specific
+		button for a specific profile. Button and profile numbers are
+		included in written data. The data has to be 2082 bytes long.
+		This file is writeonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/profile_buttons
+Date:		August 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The mouse can store 5 profiles which can be switched by the
+		press of a button. A profile is split in settings and buttons.
+		profile_buttons holds informations about button layout.
+		When written, this file lets one write the respective profile
+		buttons back to the mouse. The data has to be 77 bytes long.
+		The mouse will reject invalid data.
+		Which profile to write is determined by the profile number
+		contained in the data.
+		This file is writeonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/profile[1-5]_buttons
+Date:		August 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The mouse can store 5 profiles which can be switched by the
+		press of a button. A profile is split in settings and buttons.
+		profile_buttons holds informations about button layout.
+		When read, these files return the respective profile buttons.
+		The returned data is 77 bytes in size.
+		This file is readonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/profile_settings
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The mouse can store 5 profiles which can be switched by the
+		press of a button. A profile is split in settings and buttons.
+		profile_settings holds informations like resolution, sensitivity
+		and light effects.
+		When written, this file lets one write the respective profile
+		settings back to the mouse. The data has to be 43 bytes long.
+		The mouse will reject invalid data.
+		Which profile to write is determined by the profile number
+		contained in the data.
+		This file is writeonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/profile[1-5]_settings
+Date:		August 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The mouse can store 5 profiles which can be switched by the
+		press of a button. A profile is split in settings and buttons.
+		profile_settings holds informations like resolution, sensitivity
+		and light effects.
+		When read, these files return the respective profile settings.
+		The returned data is 43 bytes in size.
+		This file is readonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/sensor
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The mouse has a tracking- and a distance-control-unit. These
+		can be activated/deactivated and the lift-off distance can be
+		set. The data has to be 6 bytes long.
+		This file is writeonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/startup_profile
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	The integer value of this attribute ranges from 0-4.
+                When read, this attribute returns the number of the profile
+                that's active when the mouse is powered on.
+		When written, this file sets the number of the startup profile
+		and the mouse activates this profile immediately.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/tcu
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	When written a calibration process for the tracking control unit
+		can be initiated/cancelled.
+		The data has to be 3 bytes long.
+		This file is writeonly.
+
+What:		/sys/bus/usb/devices/<busnum>-<devnum>:<config num>.<interface num>/tcu_image
+Date:		October 2010
+Contact:	Stefan Achatz <erazor_de@users.sourceforge.net>
+Description:	When read the mouse returns a 30x30 pixel image of the
+		sampled underground. This works only in the course of a
+		calibration process initiated with tcu.
+		The returned data is 1028 bytes in size.
+		This file is readonly.
diff --git a/drivers/hid/Kconfig b/drivers/hid/Kconfig
index 3052e29..6199de4 100644
--- a/drivers/hid/Kconfig
+++ b/drivers/hid/Kconfig
@@ -396,6 +396,13 @@ config HID_ROCCAT_KONE
 	---help---
 	Support for Roccat Kone mouse.
 
+config HID_ROCCAT_KONEPLUS
+	tristate "Roccat Kone[+] mouse support"
+	depends on USB_HID
+	select HID_ROCCAT
+	---help---
+	Support for Roccat Kone[+] mouse.
+
 config HID_ROCCAT_PYRA
 	tristate "Roccat Pyra mouse support"
 	depends on USB_HID
diff --git a/drivers/hid/Makefile b/drivers/hid/Makefile
index c335605..ab152ce 100644
--- a/drivers/hid/Makefile
+++ b/drivers/hid/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_HID_PETALYNX)	+= hid-petalynx.o
 obj-$(CONFIG_HID_PICOLCD)	+= hid-picolcd.o
 obj-$(CONFIG_HID_ROCCAT)	+= hid-roccat.o
 obj-$(CONFIG_HID_ROCCAT_KONE)	+= hid-roccat-kone.o
+obj-$(CONFIG_HID_ROCCAT_KONEPLUS)	+= hid-roccat-koneplus.o
 obj-$(CONFIG_HID_ROCCAT_PYRA)	+= hid-roccat-pyra.o
 obj-$(CONFIG_HID_SAMSUNG)	+= hid-samsung.o
 obj-$(CONFIG_HID_SMARTJOYPLUS)	+= hid-sjoy.o
diff --git a/drivers/hid/hid-core.c b/drivers/hid/hid-core.c
index 515345b..a12fc16 100644
--- a/drivers/hid/hid-core.c
+++ b/drivers/hid/hid-core.c
@@ -1369,6 +1369,7 @@ static const struct hid_device_id hid_blacklist[] = {
 	{ HID_USB_DEVICE(USB_VENDOR_ID_QUANTA, USB_DEVICE_ID_QUANTA_OPTICAL_TOUCH) },
 	{ HID_USB_DEVICE(USB_VENDOR_ID_QUANTA, USB_DEVICE_ID_PIXART_IMAGING_INC_OPTICAL_TOUCH_SCREEN) },
 	{ HID_USB_DEVICE(USB_VENDOR_ID_ROCCAT, USB_DEVICE_ID_ROCCAT_KONE) },
+	{ HID_USB_DEVICE(USB_VENDOR_ID_ROCCAT, USB_DEVICE_ID_ROCCAT_KONEPLUS) },
 	{ HID_USB_DEVICE(USB_VENDOR_ID_ROCCAT, USB_DEVICE_ID_ROCCAT_PYRA_WIRED) },
 	{ HID_USB_DEVICE(USB_VENDOR_ID_SAMSUNG, USB_DEVICE_ID_SAMSUNG_IR_REMOTE) },
 	{ HID_USB_DEVICE(USB_VENDOR_ID_SAMSUNG, USB_DEVICE_ID_SAMSUNG_WIRELESS_KBD_MOUSE) },
diff --git a/drivers/hid/hid-ids.h b/drivers/hid/hid-ids.h
index 3341baa..43d914e 100644
--- a/drivers/hid/hid-ids.h
+++ b/drivers/hid/hid-ids.h
@@ -475,6 +475,7 @@
 
 #define USB_VENDOR_ID_ROCCAT		0x1e7d
 #define USB_DEVICE_ID_ROCCAT_KONE	0x2ced
+#define USB_DEVICE_ID_ROCCAT_KONEPLUS	0x2d51
 #define USB_DEVICE_ID_ROCCAT_PYRA_WIRED	0x2c24
 #define USB_DEVICE_ID_ROCCAT_PYRA_WIRELESS	0x2cf6
 
diff --git a/drivers/hid/hid-roccat-koneplus.c b/drivers/hid/hid-roccat-koneplus.c
new file mode 100644
index 0000000..1608c8d
--- /dev/null
+++ b/drivers/hid/hid-roccat-koneplus.c
@@ -0,0 +1,837 @@
+/*
+ * Roccat Kone[+] driver for Linux
+ *
+ * Copyright (c) 2010 Stefan Achatz <erazor_de@users.sourceforge.net>
+ */
+
+/*
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ */
+
+/*
+ * Roccat Kone[+] is an updated/improved version of the Kone with more memory
+ * and functionality and without the non-standard behaviours the Kone had.
+ */
+
+#include <linux/device.h>
+#include <linux/input.h>
+#include <linux/hid.h>
+#include <linux/usb.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include "hid-ids.h"
+#include "hid-roccat.h"
+#include "hid-roccat-koneplus.h"
+
+static uint profile_numbers[5] = {0, 1, 2, 3, 4};
+
+static struct class *koneplus_class;
+
+static void koneplus_profile_activated(struct koneplus_device *koneplus,
+		uint new_profile)
+{
+	koneplus->actual_profile = new_profile;
+}
+
+static int koneplus_send_control(struct usb_device *usb_dev, uint value,
+		enum koneplus_control_requests request)
+{
+	int len;
+	struct koneplus_control *control;
+
+	if ((request == KONEPLUS_CONTROL_REQUEST_PROFILE_SETTINGS ||
+			request == KONEPLUS_CONTROL_REQUEST_PROFILE_BUTTONS) &&
+			value > 4)
+		return -EINVAL;
+
+	control = kmalloc(sizeof(struct koneplus_control), GFP_KERNEL);
+	if (!control)
+		return -ENOMEM;
+
+	control->command = KONEPLUS_COMMAND_CONTROL;
+	control->value = value;
+	control->request = request;
+
+	len = usb_control_msg(usb_dev, usb_sndctrlpipe(usb_dev, 0),
+			USB_REQ_SET_CONFIGURATION,
+			USB_TYPE_CLASS | USB_RECIP_INTERFACE | USB_DIR_OUT,
+			KONEPLUS_USB_COMMAND_CONTROL, 0, control,
+			sizeof(struct koneplus_control),
+			USB_CTRL_SET_TIMEOUT);
+
+	kfree(control);
+
+	if (len != sizeof(struct koneplus_control))
+		return len;
+
+	return 0;
+}
+
+static int koneplus_receive(struct usb_device *usb_dev, uint usb_command,
+		void *buf, uint size) {
+	int len;
+
+	len = usb_control_msg(usb_dev, usb_rcvctrlpipe(usb_dev, 0),
+			USB_REQ_CLEAR_FEATURE,
+			USB_TYPE_CLASS | USB_RECIP_INTERFACE | USB_DIR_IN,
+			usb_command, 0, buf, size, USB_CTRL_SET_TIMEOUT);
+
+	return (len != size) ? -EIO : 0;
+}
+
+static int koneplus_receive_control_status(struct usb_device *usb_dev)
+{
+	int retval;
+	struct koneplus_control *control;
+
+	control = kmalloc(sizeof(struct koneplus_control), GFP_KERNEL);
+	if (!control)
+		return -ENOMEM;
+
+	do {
+		retval = koneplus_receive(usb_dev, KONEPLUS_USB_COMMAND_CONTROL,
+				control, sizeof(struct koneplus_control));
+
+		/* check if we get a completely wrong answer */
+		if (retval)
+			goto out;
+
+		if (control->value == KONEPLUS_CONTROL_REQUEST_STATUS_OK) {
+			retval = 0;
+			goto out;
+		}
+
+		/* indicates that hardware needs some more time to complete action */
+		if (control->value == KONEPLUS_CONTROL_REQUEST_STATUS_WAIT) {
+			msleep(500); /* windows driver uses 1000 */
+			continue;
+		}
+
+		/* seems to be critical - replug necessary */
+		if (control->value == KONEPLUS_CONTROL_REQUEST_STATUS_OVERLOAD) {
+			retval = -EINVAL;
+			goto out;
+		}
+
+		dev_err(&usb_dev->dev, "koneplus_receive_control_status: "
+				"unknown response value 0x%x\n", control->value);
+		retval = -EINVAL;
+		goto out;
+
+	} while (1);
+out:
+	kfree(control);
+	return retval;
+}
+
+static int koneplus_send(struct usb_device *usb_dev, uint command,
+		void *buf, uint size) {
+	int len;
+
+	len = usb_control_msg(usb_dev, usb_sndctrlpipe(usb_dev, 0),
+			USB_REQ_SET_CONFIGURATION,
+			USB_TYPE_CLASS | USB_RECIP_INTERFACE | USB_DIR_OUT,
+			command, 0, buf, size, USB_CTRL_SET_TIMEOUT);
+
+	if (len != size)
+		return -EIO;
+
+	if (koneplus_receive_control_status(usb_dev))
+		return -EIO;
+
+	return 0;
+}
+
+static int koneplus_select_profile(struct usb_device *usb_dev, uint number,
+		enum koneplus_control_requests request)
+{
+	int retval;
+
+	retval = koneplus_send_control(usb_dev, number, request);
+	if (retval)
+		return retval;
+
+	/* allow time to settle things - windows driver uses 500 */
+	msleep(100);
+
+	retval = koneplus_receive_control_status(usb_dev);
+	if (retval)
+		return retval;
+
+	return 0;
+}
+
+static int koneplus_get_info(struct usb_device *usb_dev,
+		struct koneplus_info *buf)
+{
+	return koneplus_receive(usb_dev, KONEPLUS_USB_COMMAND_INFO,
+			buf, sizeof(struct koneplus_info));
+}
+
+static int koneplus_get_profile_settings(struct usb_device *usb_dev,
+		struct koneplus_profile_settings *buf, uint number)
+{
+	int retval;
+
+	retval = koneplus_select_profile(usb_dev, number,
+			KONEPLUS_CONTROL_REQUEST_PROFILE_SETTINGS);
+	if (retval)
+		return retval;
+
+	return koneplus_receive(usb_dev, KONEPLUS_USB_COMMAND_PROFILE_SETTINGS,
+			buf, sizeof(struct koneplus_profile_settings));
+}
+
+static int koneplus_set_profile_settings(struct usb_device *usb_dev,
+		struct koneplus_profile_settings const *settings)
+{
+	return koneplus_send(usb_dev, KONEPLUS_USB_COMMAND_PROFILE_SETTINGS,
+			(void *)settings, sizeof(struct koneplus_profile_settings));
+}
+
+static int koneplus_get_profile_buttons(struct usb_device *usb_dev,
+		struct koneplus_profile_buttons *buf, int number)
+{
+	int retval;
+
+	retval = koneplus_select_profile(usb_dev, number,
+			KONEPLUS_CONTROL_REQUEST_PROFILE_BUTTONS);
+	if (retval)
+		return retval;
+
+	return koneplus_receive(usb_dev, KONEPLUS_USB_COMMAND_PROFILE_BUTTONS,
+			buf, sizeof(struct koneplus_profile_buttons));
+}
+
+static int koneplus_set_profile_buttons(struct usb_device *usb_dev,
+		struct koneplus_profile_buttons const *buttons)
+{
+	return koneplus_send(usb_dev, KONEPLUS_USB_COMMAND_PROFILE_BUTTONS,
+			(void *)buttons, sizeof(struct koneplus_profile_buttons));
+}
+
+/* retval is 0-4 on success, < 0 on error */
+static int koneplus_get_startup_profile(struct usb_device *usb_dev)
+{
+	struct koneplus_startup_profile *buf;
+	int retval;
+
+	buf = kmalloc(sizeof(struct koneplus_startup_profile), GFP_KERNEL);
+
+	retval = koneplus_receive(usb_dev, KONEPLUS_USB_COMMAND_STARTUP_PROFILE,
+			buf, sizeof(struct koneplus_startup_profile));
+
+	if (retval)
+		goto out;
+
+	retval = buf->startup_profile;
+out:
+	kfree(buf);
+	return retval;
+}
+
+static int koneplus_set_startup_profile(struct usb_device *usb_dev,
+		int startup_profile)
+{
+	struct koneplus_startup_profile buf;
+
+	buf.command = KONEPLUS_COMMAND_STARTUP_PROFILE;
+	buf.size = sizeof(struct koneplus_startup_profile);
+	buf.startup_profile = startup_profile;
+
+	return koneplus_send(usb_dev, KONEPLUS_USB_COMMAND_STARTUP_PROFILE,
+			(char *)&buf, sizeof(struct koneplus_profile_buttons));
+}
+
+static ssize_t koneplus_sysfs_read(struct file *fp, struct kobject *kobj,
+		char *buf, loff_t off, size_t count,
+		size_t real_size, uint command)
+{
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
+	struct koneplus_device *koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	int retval;
+
+	if (off != 0 || count != real_size)
+		return -EINVAL;
+
+	mutex_lock(&koneplus->koneplus_lock);
+	retval = koneplus_receive(usb_dev, command, buf, real_size);
+	mutex_unlock(&koneplus->koneplus_lock);
+
+	if (retval)
+		return retval;
+
+	return real_size;
+}
+
+static ssize_t koneplus_sysfs_write(struct file *fp, struct kobject *kobj,
+		void const *buf, loff_t off, size_t count,
+		size_t real_size, uint command)
+{
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
+	struct koneplus_device *koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	int retval;
+
+	if (off != 0 || count != real_size)
+		return -EINVAL;
+
+	mutex_lock(&koneplus->koneplus_lock);
+	retval = koneplus_send(usb_dev, command, (void *)buf, real_size);
+	mutex_unlock(&koneplus->koneplus_lock);
+
+	if (retval)
+		return retval;
+
+	return real_size;
+}
+
+static ssize_t koneplus_sysfs_write_macro(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	return koneplus_sysfs_write(fp, kobj, buf, off, count,
+			sizeof(struct koneplus_macro), KONEPLUS_USB_COMMAND_MACRO);
+}
+
+static ssize_t koneplus_sysfs_read_sensor(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	return koneplus_sysfs_read(fp, kobj, buf, off, count,
+			sizeof(struct koneplus_sensor), KONEPLUS_USB_COMMAND_SENSOR);
+}
+
+static ssize_t koneplus_sysfs_write_sensor(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	return koneplus_sysfs_write(fp, kobj, buf, off, count,
+			sizeof(struct koneplus_sensor), KONEPLUS_USB_COMMAND_SENSOR);
+}
+
+static ssize_t koneplus_sysfs_write_tcu(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	return koneplus_sysfs_write(fp, kobj, buf, off, count,
+			sizeof(struct koneplus_tcu), KONEPLUS_USB_COMMAND_TCU);
+}
+
+static ssize_t koneplus_sysfs_read_tcu_image(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	return koneplus_sysfs_read(fp, kobj, buf, off, count,
+			sizeof(struct koneplus_tcu_image), KONEPLUS_USB_COMMAND_TCU);
+}
+
+static ssize_t koneplus_sysfs_read_profilex_settings(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
+	struct koneplus_device *koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+
+	if (off >= sizeof(struct koneplus_profile_settings))
+		return 0;
+
+	if (off + count > sizeof(struct koneplus_profile_settings))
+		count = sizeof(struct koneplus_profile_settings) - off;
+
+	mutex_lock(&koneplus->koneplus_lock);
+	memcpy(buf, ((void const *)&koneplus->profile_settings[*(uint *)(attr->private)]) + off,
+			count);
+	mutex_unlock(&koneplus->koneplus_lock);
+
+	return count;
+}
+
+static ssize_t koneplus_sysfs_write_profile_settings(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
+	struct koneplus_device *koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	int retval = 0;
+	int difference;
+	int profile_number;
+	struct koneplus_profile_settings *profile_settings;
+
+	if (off != 0 || count != sizeof(struct koneplus_profile_settings))
+		return -EINVAL;
+
+	profile_number = ((struct koneplus_profile_settings const *)buf)->number;
+	profile_settings = &koneplus->profile_settings[profile_number];
+
+	mutex_lock(&koneplus->koneplus_lock);
+	difference = memcmp(buf, profile_settings,
+			sizeof(struct koneplus_profile_settings));
+	if (difference) {
+		retval = koneplus_set_profile_settings(usb_dev,
+				(struct koneplus_profile_settings const *)buf);
+		if (!retval)
+			memcpy(profile_settings, buf,
+					sizeof(struct koneplus_profile_settings));
+	}
+	mutex_unlock(&koneplus->koneplus_lock);
+
+	if (retval)
+		return retval;
+
+	return sizeof(struct koneplus_profile_settings);
+}
+
+static ssize_t koneplus_sysfs_read_profilex_buttons(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
+	struct koneplus_device *koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+
+	if (off >= sizeof(struct koneplus_profile_buttons))
+		return 0;
+
+	if (off + count > sizeof(struct koneplus_profile_buttons))
+		count = sizeof(struct koneplus_profile_buttons) - off;
+
+	mutex_lock(&koneplus->koneplus_lock);
+	memcpy(buf, ((void const *)&koneplus->profile_buttons[*(uint *)(attr->private)]) + off,
+			count);
+	mutex_unlock(&koneplus->koneplus_lock);
+
+	return count;
+}
+
+static ssize_t koneplus_sysfs_write_profile_buttons(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr, char *buf,
+		loff_t off, size_t count)
+{
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
+	struct koneplus_device *koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	int retval = 0;
+	int difference;
+	uint profile_number;
+	struct koneplus_profile_buttons *profile_buttons;
+
+	if (off != 0 || count != sizeof(struct koneplus_profile_buttons))
+		return -EINVAL;
+
+	profile_number = ((struct koneplus_profile_buttons const *)buf)->number;
+	profile_buttons = &koneplus->profile_buttons[profile_number];
+
+	mutex_lock(&koneplus->koneplus_lock);
+	difference = memcmp(buf, profile_buttons,
+			sizeof(struct koneplus_profile_buttons));
+	if (difference) {
+		retval = koneplus_set_profile_buttons(usb_dev,
+				(struct koneplus_profile_buttons const *)buf);
+		if (!retval)
+			memcpy(profile_buttons, buf,
+					sizeof(struct koneplus_profile_buttons));
+	}
+	mutex_unlock(&koneplus->koneplus_lock);
+
+	if (retval)
+		return retval;
+
+	return sizeof(struct koneplus_profile_buttons);
+}
+
+static ssize_t koneplus_sysfs_show_startup_profile(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct koneplus_device *koneplus =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
+	return snprintf(buf, PAGE_SIZE, "%d\n", koneplus->startup_profile);
+}
+
+static ssize_t koneplus_sysfs_set_startup_profile(struct device *dev,
+		struct device_attribute *attr, char const *buf, size_t size)
+{
+	struct koneplus_device *koneplus;
+	struct usb_device *usb_dev;
+	unsigned long profile;
+	int retval;
+
+	dev = dev->parent->parent;
+	koneplus = hid_get_drvdata(dev_get_drvdata(dev));
+	usb_dev = interface_to_usbdev(to_usb_interface(dev));
+
+	retval = strict_strtoul(buf, 10, &profile);
+	if (retval)
+		return retval;
+
+	mutex_lock(&koneplus->koneplus_lock);
+	retval = koneplus_set_startup_profile(usb_dev, profile);
+	mutex_unlock(&koneplus->koneplus_lock);
+	if (retval)
+		return retval;
+
+	return size;
+}
+
+static ssize_t koneplus_sysfs_show_actual_profile(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct koneplus_device *koneplus =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
+	return snprintf(buf, PAGE_SIZE, "%d\n", koneplus->actual_profile);
+}
+
+static ssize_t koneplus_sysfs_show_firmware_version(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct koneplus_device *koneplus =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
+	return snprintf(buf, PAGE_SIZE, "%d\n", koneplus->info.firmware_version);
+}
+
+static struct device_attribute koneplus_attributes[] = {
+	__ATTR(startup_profile, 0660,
+			koneplus_sysfs_show_startup_profile,
+			koneplus_sysfs_set_startup_profile),
+	__ATTR(actual_profile, 0440,
+			koneplus_sysfs_show_actual_profile, NULL),
+	__ATTR(firmware_version, 0440,
+			koneplus_sysfs_show_firmware_version, NULL),
+	__ATTR_NULL
+};
+
+static struct bin_attribute koneplus_bin_attributes[] = {
+	{
+		.attr = { .name = "sensor", .mode = 0220 },
+		.size = sizeof(struct koneplus_sensor),
+		.read = koneplus_sysfs_read_sensor,
+		.write = koneplus_sysfs_write_sensor
+	},
+	{
+		.attr = { .name = "tcu", .mode = 0220 },
+		.size = sizeof(struct koneplus_tcu),
+		.write = koneplus_sysfs_write_tcu
+	},
+	{
+		.attr = { .name = "tcu_image", .mode = 0440 },
+		.size = sizeof(struct koneplus_tcu_image),
+		.read = koneplus_sysfs_read_tcu_image
+	},
+	{
+		.attr = { .name = "profile_settings", .mode = 0220 },
+		.size = sizeof(struct koneplus_profile_settings),
+		.write = koneplus_sysfs_write_profile_settings
+	},
+	{
+		.attr = { .name = "profile1_settings", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_settings),
+		.read = koneplus_sysfs_read_profilex_settings,
+		.private = &profile_numbers[0]
+	},
+	{
+		.attr = { .name = "profile2_settings", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_settings),
+		.read = koneplus_sysfs_read_profilex_settings,
+		.private = &profile_numbers[1]
+	},
+	{
+		.attr = { .name = "profile3_settings", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_settings),
+		.read = koneplus_sysfs_read_profilex_settings,
+		.private = &profile_numbers[2]
+	},
+	{
+		.attr = { .name = "profile4_settings", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_settings),
+		.read = koneplus_sysfs_read_profilex_settings,
+		.private = &profile_numbers[3]
+	},
+	{
+		.attr = { .name = "profile5_settings", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_settings),
+		.read = koneplus_sysfs_read_profilex_settings,
+		.private = &profile_numbers[4]
+	},
+	{
+		.attr = { .name = "profile_buttons", .mode = 0220 },
+		.size = sizeof(struct koneplus_profile_buttons),
+		.write = koneplus_sysfs_write_profile_buttons
+	},
+	{
+		.attr = { .name = "profile1_buttons", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_buttons),
+		.read = koneplus_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[0]
+	},
+	{
+		.attr = { .name = "profile2_buttons", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_buttons),
+		.read = koneplus_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[1]
+	},
+	{
+		.attr = { .name = "profile3_buttons", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_buttons),
+		.read = koneplus_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[2]
+	},
+	{
+		.attr = { .name = "profile4_buttons", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_buttons),
+		.read = koneplus_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[3]
+	},
+	{
+		.attr = { .name = "profile5_buttons", .mode = 0440 },
+		.size = sizeof(struct koneplus_profile_buttons),
+		.read = koneplus_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[4]
+	},
+	{
+		.attr = { .name = "macro", .mode = 0220 },
+		.size = sizeof(struct koneplus_macro),
+		.write = koneplus_sysfs_write_macro
+	},
+	__ATTR_NULL
+};
+
+static int koneplus_init_koneplus_device_struct(struct usb_device *usb_dev,
+		struct koneplus_device *koneplus)
+{
+	int retval, i;
+	static uint wait = 70; /* device will freeze with just 60 */
+
+	mutex_init(&koneplus->koneplus_lock);
+
+	koneplus->startup_profile = koneplus_get_startup_profile(usb_dev);
+
+	msleep(wait);
+	retval = koneplus_get_info(usb_dev, &koneplus->info);
+	if (retval)
+		return retval;
+
+	for (i = 0; i < 5; ++i) {
+		msleep(wait);
+		retval = koneplus_get_profile_settings(usb_dev,
+				&koneplus->profile_settings[i], i);
+		if (retval)
+			return retval;
+
+		msleep(wait);
+		retval = koneplus_get_profile_buttons(usb_dev,
+				&koneplus->profile_buttons[i], i);
+		if (retval)
+			return retval;
+	}
+
+	koneplus_profile_activated(koneplus, koneplus->startup_profile);
+
+	return 0;
+}
+
+static int koneplus_init_specials(struct hid_device *hdev)
+{
+	struct usb_interface *intf = to_usb_interface(hdev->dev.parent);
+	struct usb_device *usb_dev = interface_to_usbdev(intf);
+	struct koneplus_device *koneplus;
+	int retval;
+
+	if (intf->cur_altsetting->desc.bInterfaceProtocol
+			== USB_INTERFACE_PROTOCOL_MOUSE) {
+
+		koneplus = kzalloc(sizeof(*koneplus), GFP_KERNEL);
+		if (!koneplus) {
+			dev_err(&hdev->dev, "can't alloc device descriptor\n");
+			return -ENOMEM;
+		}
+		hid_set_drvdata(hdev, koneplus);
+
+		retval = koneplus_init_koneplus_device_struct(usb_dev, koneplus);
+		if (retval) {
+			dev_err(&hdev->dev,
+					"couldn't init struct koneplus_device\n");
+			goto exit_free;
+		}
+
+		retval = roccat_connect(koneplus_class, hdev);
+		if (retval < 0) {
+			dev_err(&hdev->dev, "couldn't init char dev\n");
+		} else {
+			koneplus->chrdev_minor = retval;
+			koneplus->roccat_claimed = 1;
+		}
+	} else {
+		hid_set_drvdata(hdev, NULL);
+	}
+
+	return 0;
+exit_free:
+	kfree(koneplus);
+	return retval;
+}
+
+static void koneplus_remove_specials(struct hid_device *hdev)
+{
+	struct usb_interface *intf = to_usb_interface(hdev->dev.parent);
+	struct koneplus_device *koneplus;
+
+	if (intf->cur_altsetting->desc.bInterfaceProtocol
+			== USB_INTERFACE_PROTOCOL_MOUSE) {
+		koneplus = hid_get_drvdata(hdev);
+		if (koneplus->roccat_claimed)
+			roccat_disconnect(koneplus->chrdev_minor);
+		kfree(koneplus);
+	}
+}
+
+static int koneplus_probe(struct hid_device *hdev,
+		const struct hid_device_id *id)
+{
+	int retval;
+
+	retval = hid_parse(hdev);
+	if (retval) {
+		dev_err(&hdev->dev, "parse failed\n");
+		goto exit;
+	}
+
+	retval = hid_hw_start(hdev, HID_CONNECT_DEFAULT);
+	if (retval) {
+		dev_err(&hdev->dev, "hw start failed\n");
+		goto exit;
+	}
+
+	retval = koneplus_init_specials(hdev);
+	if (retval) {
+		dev_err(&hdev->dev, "couldn't install mouse\n");
+		goto exit_stop;
+	}
+
+	return 0;
+
+exit_stop:
+	hid_hw_stop(hdev);
+exit:
+	return retval;
+}
+
+static void koneplus_remove(struct hid_device *hdev)
+{
+	koneplus_remove_specials(hdev);
+	hid_hw_stop(hdev);
+}
+
+static void koneplus_keep_values_up_to_date(struct koneplus_device *koneplus,
+		u8 const *data)
+{
+	struct koneplus_mouse_report_button const *button_report;
+
+	switch (data[0]) {
+	case KONEPLUS_MOUSE_REPORT_NUMBER_BUTTON:
+		button_report = (struct koneplus_mouse_report_button const *)data;
+		switch (button_report->type) {
+		case KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_PROFILE:
+			koneplus_profile_activated(koneplus, button_report->data1 - 1);
+			break;
+		}
+		break;
+	}
+}
+
+static void koneplus_report_to_chrdev(struct koneplus_device const *koneplus,
+		u8 const *data)
+{
+	struct koneplus_roccat_report roccat_report;
+	struct koneplus_mouse_report_button const *button_report;
+
+	if (data[0] != KONEPLUS_MOUSE_REPORT_NUMBER_BUTTON)
+		return;
+
+	button_report = (struct koneplus_mouse_report_button const *)data;
+
+	if ((button_report->type == KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_QUICKLAUNCH ||
+			button_report->type == KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_TIMER) &&
+			button_report->data2 != KONEPLUS_MOUSE_REPORT_BUTTON_ACTION_PRESS)
+		return;
+
+	roccat_report.type = button_report->type;
+	roccat_report.data1 = button_report->data1;
+	roccat_report.data2 = button_report->data2;
+	roccat_report.profile = koneplus->actual_profile + 1;
+	roccat_report_event(koneplus->chrdev_minor,
+			(uint8_t const *)&roccat_report,
+			sizeof(struct koneplus_roccat_report));
+}
+
+static int koneplus_raw_event(struct hid_device *hdev,
+		struct hid_report *report, u8 *data, int size)
+{
+	struct usb_interface *intf = to_usb_interface(hdev->dev.parent);
+	struct koneplus_device *koneplus = hid_get_drvdata(hdev);
+
+	if (intf->cur_altsetting->desc.bInterfaceProtocol
+			!= USB_INTERFACE_PROTOCOL_MOUSE)
+		return 0;
+
+	koneplus_keep_values_up_to_date(koneplus, data);
+
+	if (koneplus->roccat_claimed)
+		koneplus_report_to_chrdev(koneplus, data);
+
+	return 0;
+}
+
+static const struct hid_device_id koneplus_devices[] = {
+	{ HID_USB_DEVICE(USB_VENDOR_ID_ROCCAT, USB_DEVICE_ID_ROCCAT_KONEPLUS) },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(hid, koneplus_devices);
+
+static struct hid_driver koneplus_driver = {
+		.name = "koneplus",
+		.id_table = koneplus_devices,
+		.probe = koneplus_probe,
+		.remove = koneplus_remove,
+		.raw_event = koneplus_raw_event
+};
+
+static int __init koneplus_init(void)
+{
+	int retval;
+
+	/* class name has to be same as driver name */
+	koneplus_class = class_create(THIS_MODULE, "koneplus");
+	if (IS_ERR(koneplus_class))
+		return PTR_ERR(koneplus_class);
+	koneplus_class->dev_attrs = koneplus_attributes;
+	koneplus_class->dev_bin_attrs = koneplus_bin_attributes;
+
+	retval = hid_register_driver(&koneplus_driver);
+	if (retval)
+		class_destroy(koneplus_class);
+	return retval;
+}
+
+static void __exit koneplus_exit(void)
+{
+	class_destroy(koneplus_class);
+	hid_unregister_driver(&koneplus_driver);
+}
+
+module_init(koneplus_init);
+module_exit(koneplus_exit);
+
+MODULE_AUTHOR("Stefan Achatz");
+MODULE_DESCRIPTION("USB Roccat Kone[+] driver");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/hid/hid-roccat-koneplus.h b/drivers/hid/hid-roccat-koneplus.h
new file mode 100644
index 0000000..905e33d
--- /dev/null
+++ b/drivers/hid/hid-roccat-koneplus.h
@@ -0,0 +1,232 @@
+#ifndef __HID_ROCCAT_KONEPLUS_H
+#define __HID_ROCCAT_KONEPLUS_H
+
+/*
+ * Copyright (c) 2010 Stefan Achatz <erazor_de@users.sourceforge.net>
+ */
+
+/*
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ */
+
+#include <linux/types.h>
+
+/*
+ * Binary data structures used for hardware communication must have no padding.
+ */
+#pragma pack(push)
+#pragma pack(1)
+
+/*
+ * case 1: writes request 80 and reads value 1
+ *
+ */
+struct koneplus_control {
+	uint8_t command; /* KONEPLUS_COMMAND_CONTROL */
+	/*
+	 * value is profile number in range 0-4 for requesting settings and buttons
+	 * 1 if status ok for requesting status
+	 */
+	uint8_t value;
+	uint8_t request;
+};
+
+enum koneplus_control_requests {
+	KONEPLUS_CONTROL_REQUEST_STATUS = 0x00,
+	KONEPLUS_CONTROL_REQUEST_PROFILE_SETTINGS = 0x80,
+	KONEPLUS_CONTROL_REQUEST_PROFILE_BUTTONS = 0x90,
+};
+
+enum koneplus_control_values {
+	KONEPLUS_CONTROL_REQUEST_STATUS_OVERLOAD = 0,
+	KONEPLUS_CONTROL_REQUEST_STATUS_OK = 1,
+	KONEPLUS_CONTROL_REQUEST_STATUS_WAIT = 3,
+};
+
+struct koneplus_startup_profile {
+	uint8_t command; /* KONEPLUS_COMMAND_STARTUP_PROFILE */
+	uint8_t size; /* always 3 */
+	uint8_t startup_profile; /* Range 0-4! */
+};
+
+struct koneplus_profile_settings {
+	uint8_t command; /* KONEPLUS_COMMAND_PROFILE_SETTINGS */
+	uint8_t size; /* always 43 */
+	uint8_t number; /* range 0-4 */
+	uint8_t advanced_sensitivity;
+	uint8_t sensitivity_x;
+	uint8_t sensitivity_y;
+	uint8_t cpi_levels_enabled;
+	uint8_t cpi_levels_x[5];
+	uint8_t cpi_startup_level; /* range 0-4 */
+	uint8_t cpi_levels_y[5]; /* range 1-60 means 100-6000 cpi */
+	uint8_t unknown1;
+	uint8_t polling_rate;
+	uint8_t lights_enabled;
+	uint8_t light_effect_mode;
+	uint8_t color_flow_effect;
+	uint8_t light_effect_type;
+	uint8_t light_effect_speed;
+	uint8_t lights[16];
+	uint16_t checksum;
+};
+
+struct koneplus_profile_buttons {
+	uint8_t command; /* KONEPLUS_COMMAND_PROFILE_BUTTONS */
+	uint8_t size; /* always 77 */
+	uint8_t number; /* range 0-4 */
+	uint8_t data[72];
+	uint16_t checksum;
+};
+
+struct koneplus_macro {
+	uint8_t command; /* KONEPLUS_COMMAND_MACRO */
+	uint16_t size; /* always 0x822 little endian */
+	uint8_t profile; /* range 0-4 */
+	uint8_t button; /* range 0-23 */
+	uint8_t data[2075];
+	uint16_t checksum;
+};
+
+struct koneplus_info {
+	uint8_t command; /* KONEPLUS_COMMAND_INFO */
+	uint8_t size; /* always 6 */
+	uint8_t firmware_version;
+	uint8_t unknown[3];
+};
+
+struct koneplus_e {
+	uint8_t command; /* KONEPLUS_COMMAND_E */
+	uint8_t size; /* always 3 */
+	uint8_t unknown; /* TODO 1; 0 before firmware update */
+};
+
+struct koneplus_sensor {
+	uint8_t command;  /* KONEPLUS_COMMAND_SENSOR */
+	uint8_t size; /* always 6 */
+	uint8_t data[4];
+};
+
+struct koneplus_firmware_write {
+	uint8_t command; /* KONEPLUS_COMMAND_FIRMWARE_WRITE */
+	uint8_t unknown[1025];
+};
+
+struct koneplus_firmware_write_control {
+	uint8_t command; /* KONEPLUS_COMMAND_FIRMWARE_WRITE_CONTROL */
+	/*
+	 * value is 1 on success
+	 * 3 means "not finished yet"
+	 */
+	uint8_t value;
+	uint8_t unknown; /* always 0x75 */
+};
+
+struct koneplus_tcu {
+	uint16_t usb_command; /* KONEPLUS_USB_COMMAND_TCU */
+	uint8_t data[2];
+};
+
+struct koneplus_tcu_image {
+	uint16_t usb_command; /* KONEPLUS_USB_COMMAND_TCU */
+	uint8_t data[1024];
+	uint16_t checksum;
+};
+
+enum koneplus_commands {
+	KONEPLUS_COMMAND_CONTROL = 0x4,
+	KONEPLUS_COMMAND_STARTUP_PROFILE = 0x5,
+	KONEPLUS_COMMAND_PROFILE_SETTINGS = 0x6,
+	KONEPLUS_COMMAND_PROFILE_BUTTONS = 0x7,
+	KONEPLUS_COMMAND_MACRO = 0x8,
+	KONEPLUS_COMMAND_INFO = 0x9,
+	KONEPLUS_COMMAND_E = 0xe,
+	KONEPLUS_COMMAND_SENSOR = 0xf,
+	KONEPLUS_COMMAND_FIRMWARE_WRITE = 0x1b,
+	KONEPLUS_COMMAND_FIRMWARE_WRITE_CONTROL = 0x1c,
+};
+
+enum koneplus_usb_commands {
+	KONEPLUS_USB_COMMAND_CONTROL = 0x304,
+	KONEPLUS_USB_COMMAND_STARTUP_PROFILE = 0x305,
+	KONEPLUS_USB_COMMAND_PROFILE_SETTINGS = 0x306,
+	KONEPLUS_USB_COMMAND_PROFILE_BUTTONS = 0x307,
+	KONEPLUS_USB_COMMAND_MACRO = 0x308,
+	KONEPLUS_USB_COMMAND_INFO = 0x309,
+	KONEPLUS_USB_COMMAND_TCU = 0x30c,
+	KONEPLUS_USB_COMMAND_E = 0x30e,
+	KONEPLUS_USB_COMMAND_SENSOR = 0x30f,
+	KONEPLUS_USB_COMMAND_FIRMWARE_WRITE = 0x31b,
+	KONEPLUS_USB_COMMAND_FIRMWARE_WRITE_CONTROL = 0x31c,
+};
+
+enum koneplus_mouse_report_numbers {
+	KONEPLUS_MOUSE_REPORT_NUMBER_HID = 1,
+	KONEPLUS_MOUSE_REPORT_NUMBER_AUDIO = 2,
+	KONEPLUS_MOUSE_REPORT_NUMBER_BUTTON = 3,
+};
+
+struct koneplus_mouse_report_button {
+	uint8_t report_number; /* always KONEPLUS_MOUSE_REPORT_NUMBER_BUTTON */
+	uint8_t zero1;
+	uint8_t type;
+	uint8_t data1;
+	uint8_t data2;
+	uint8_t zero2;
+	uint8_t unknown[2];
+};
+
+enum koneplus_mouse_report_button_types {
+	/* data1 = new profile range 1-5 */
+	KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_PROFILE = 0x20,
+
+	/* data1 = button number range 1-24; data2 = action */
+	KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_QUICKLAUNCH = 0x60,
+
+	/* data1 = button number range 1-24; data2 = action */
+	KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_TIMER = 0x80,
+
+	/* data1 = setting number range 1-5 */
+	KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_CPI = 0xb0,
+
+	/* data1 and data2 = range 0x1-0xb */
+	KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_SENSITIVITY = 0xc0,
+
+	/* data1 = 22 = next track...
+	 * data2 = action
+	 */
+	KONEPLUS_MOUSE_REPORT_BUTTON_TYPE_MULTIMEDIA = 0xf0,
+};
+
+enum koneplus_mouse_report_button_action {
+	KONEPLUS_MOUSE_REPORT_BUTTON_ACTION_PRESS = 0,
+	KONEPLUS_MOUSE_REPORT_BUTTON_ACTION_RELEASE = 1,
+};
+
+struct koneplus_roccat_report {
+	uint8_t type;
+	uint8_t data1;
+	uint8_t data2;
+	uint8_t profile;
+};
+
+#pragma pack(pop)
+
+struct koneplus_device {
+	int actual_profile;
+
+	int roccat_claimed;
+	int chrdev_minor;
+
+	struct mutex koneplus_lock;
+
+	int startup_profile;
+	struct koneplus_info info;
+	struct koneplus_profile_settings profile_settings[5];
+	struct koneplus_profile_buttons profile_buttons[5];
+};
+
+#endif
-- 
1.7.2.3



