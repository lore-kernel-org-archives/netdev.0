From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next v2 1/2] device property: Return -ENXIO if there is no suitable FW interface
Date: Wed, 26 Aug 2015 13:20:44 -0700
Message-ID: <1440620445-14413-1-git-send-email-linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>, tony@atomide.com,
	Guenter Roeck <linux@roeck-us.net>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return -ENXIO if device property array access functions don't find
a suitable firmware interface.

This lets drivers decide if they should use available platform data
instead.

Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2: Added patch

 drivers/base/property.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index 287704d680bf..9600b824d138 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -69,6 +69,9 @@ static int pset_prop_read_array(struct property_set *pset, const char *name,
 	struct property_entry *prop;
 	unsigned int item_size;
 
+	if (!pset)
+		return -ENXIO;
+
 	prop = pset_prop_get(pset, name);
 	if (!prop)
 		return -ENODATA;
@@ -156,6 +159,7 @@ EXPORT_SYMBOL_GPL(fwnode_property_present);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u8_array(struct device *dev, const char *propname,
 				  u8 *val, size_t nval)
@@ -180,6 +184,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u8_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u16_array(struct device *dev, const char *propname,
 				   u16 *val, size_t nval)
@@ -204,6 +209,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u16_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u32_array(struct device *dev, const char *propname,
 				   u32 *val, size_t nval)
@@ -228,6 +234,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u32_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u64_array(struct device *dev, const char *propname,
 				   u64 *val, size_t nval)
-- 
2.1.4
