From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/11] drivers/uwb: Rename dev_info to wdi
Date: Mon,  5 Apr 2010 12:05:41 -0700
Message-ID: <6bd4d4dacf32631b72c3827a3b133a26e2e8b889.1270493677.git.joe@perches.com>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
Cc: David Vrabel <david.vrabel@csr.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1385 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207Ab0DETF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 15:05:57 -0400
In-Reply-To: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
In-Reply-To: <cover.1270493677.git.joe@perches.com>
References: <cover.1270493677.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a macro called dev_info that prints struct device specific
information.  Having variables with the same name can be confusing and
prevents conversion of the macro to a function.

Rename the existing dev_info variables to something else in preparation
to converting the dev_info macro to a function.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/uwb/i1480/i1480u-wlp/lc.c |   16 ++++++------
 drivers/uwb/wlp/messages.c        |   40 ++++++++++++++++----------------
 drivers/uwb/wlp/sysfs.c           |   46 ++++++++++++++++++------------------
 drivers/uwb/wlp/wlp-lc.c          |   12 +++++-----
 4 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/drivers/uwb/i1480/i1480u-wlp/lc.c b/drivers/uwb/i1480/i1480u-wlp/lc.c
index f272dfe..bd52675 100644
--- a/drivers/uwb/i1480/i1480u-wlp/lc.c
+++ b/drivers/uwb/i1480/i1480u-wlp/lc.c
@@ -92,28 +92,28 @@ void i1480u_init(struct i1480u *i1480u)
  * information elements have intuitive mappings, other not.
  */
 static
-void i1480u_fill_device_info(struct wlp *wlp, struct wlp_device_info *dev_info)
+void i1480u_fill_device_info(struct wlp *wlp, struct wlp_device_info *wdi)
 {
 	struct i1480u *i1480u = container_of(wlp, struct i1480u, wlp);
 	struct usb_device *usb_dev = i1480u->usb_dev;
 	/* Treat device name and model name the same */
 	if (usb_dev->descriptor.iProduct) {
 		usb_string(usb_dev, usb_dev->descriptor.iProduct,
-			   dev_info->name, sizeof(dev_info->name));
+			   wdi->name, sizeof(wdi->name));
 		usb_string(usb_dev, usb_dev->descriptor.iProduct,
-			   dev_info->model_name, sizeof(dev_info->model_name));
+			   wdi->model_name, sizeof(wdi->model_name));
 	}
 	if (usb_dev->descriptor.iManufacturer)
 		usb_string(usb_dev, usb_dev->descriptor.iManufacturer,
-			   dev_info->manufacturer,
-			   sizeof(dev_info->manufacturer));
-	scnprintf(dev_info->model_nr, sizeof(dev_info->model_nr), "%04x",
+			   wdi->manufacturer,
+			   sizeof(wdi->manufacturer));
+	scnprintf(wdi->model_nr, sizeof(wdi->model_nr), "%04x",
 		  __le16_to_cpu(usb_dev->descriptor.bcdDevice));
 	if (usb_dev->descriptor.iSerialNumber)
 		usb_string(usb_dev, usb_dev->descriptor.iSerialNumber,
-			   dev_info->serial, sizeof(dev_info->serial));
+			   wdi->serial, sizeof(wdi->serial));
 	/* FIXME: where should we obtain category? */
-	dev_info->prim_dev_type.category = cpu_to_le16(WLP_DEV_CAT_OTHER);
+	wdi->prim_dev_type.category = cpu_to_le16(WLP_DEV_CAT_OTHER);
 	/* FIXME: Complete OUI and OUIsubdiv attributes */
 }
 
diff --git a/drivers/uwb/wlp/messages.c b/drivers/uwb/wlp/messages.c
index 7516486..4057942 100644
--- a/drivers/uwb/wlp/messages.c
+++ b/drivers/uwb/wlp/messages.c
@@ -712,7 +712,7 @@ static int wlp_build_assoc_d1(struct wlp *wlp, struct wlp_wss *wss,
 	struct sk_buff *_skb;
 	void *d1_itr;
 
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_setup_device_info(wlp);
 		if (result < 0) {
 			dev_err(dev, "WLP: Unable to setup device "
@@ -720,7 +720,7 @@ static int wlp_build_assoc_d1(struct wlp *wlp, struct wlp_wss *wss,
 			goto error;
 		}
 	}
-	info = wlp->dev_info;
+	info = wlp->wdi;
 	_skb = dev_alloc_skb(sizeof(*_d1)
 		      + sizeof(struct wlp_attr_uuid_e)
 		      + sizeof(struct wlp_attr_wss_sel_mthd)
@@ -794,7 +794,7 @@ int wlp_build_assoc_d2(struct wlp *wlp, struct wlp_wss *wss,
 	void *d2_itr;
 	size_t mem_needed;
 
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_setup_device_info(wlp);
 		if (result < 0) {
 			dev_err(dev, "WLP: Unable to setup device "
@@ -802,7 +802,7 @@ int wlp_build_assoc_d2(struct wlp *wlp, struct wlp_wss *wss,
 			goto error;
 		}
 	}
-	info = wlp->dev_info;
+	info = wlp->wdi;
 	mem_needed = sizeof(*_d2)
 		      + sizeof(struct wlp_attr_uuid_e)
 		      + sizeof(struct wlp_attr_uuid_r)
@@ -970,7 +970,7 @@ error_parse:
  */
 static
 int wlp_get_variable_info(struct wlp *wlp, void *data,
-			  struct wlp_device_info *dev_info, ssize_t len)
+			  struct wlp_device_info *wdi, ssize_t len)
 {
 	struct device *dev = &wlp->rc->uwb_dev.dev;
 	size_t used = 0;
@@ -993,7 +993,7 @@ int wlp_get_variable_info(struct wlp *wlp, void *data,
 				goto error_parse;
 			}
 			result = wlp_get_manufacturer(wlp, data + used,
-						      dev_info->manufacturer,
+						      wdi->manufacturer,
 						      len - used);
 			if (result < 0) {
 				dev_err(dev, "WLP: Unable to obtain "
@@ -1011,7 +1011,7 @@ int wlp_get_variable_info(struct wlp *wlp, void *data,
 				goto error_parse;
 			}
 			result = wlp_get_model_name(wlp, data + used,
-						    dev_info->model_name,
+						    wdi->model_name,
 						    len - used);
 			if (result < 0) {
 				dev_err(dev, "WLP: Unable to obtain Model "
@@ -1028,7 +1028,7 @@ int wlp_get_variable_info(struct wlp *wlp, void *data,
 				goto error_parse;
 			}
 			result = wlp_get_model_nr(wlp, data + used,
-						  dev_info->model_nr,
+						  wdi->model_nr,
 						  len - used);
 			if (result < 0) {
 				dev_err(dev, "WLP: Unable to obtain Model "
@@ -1045,7 +1045,7 @@ int wlp_get_variable_info(struct wlp *wlp, void *data,
 				goto error_parse;
 			}
 			result = wlp_get_serial(wlp, data + used,
-						dev_info->serial, len - used);
+						wdi->serial, len - used);
 			if (result < 0) {
 				dev_err(dev, "WLP: Unable to obtain Serial "
 					"number attribute from D1 message.\n");
@@ -1061,7 +1061,7 @@ int wlp_get_variable_info(struct wlp *wlp, void *data,
 				goto error_parse;
 			}
 			result = wlp_get_prim_dev_type(wlp, data + used,
-						       &dev_info->prim_dev_type,
+						       &wdi->prim_dev_type,
 						       len - used);
 			if (result < 0) {
 				dev_err(dev, "WLP: Unable to obtain Primary "
@@ -1069,10 +1069,10 @@ int wlp_get_variable_info(struct wlp *wlp, void *data,
 					"message.\n");
 				goto error_parse;
 			}
-			dev_info->prim_dev_type.category =
-				le16_to_cpu(dev_info->prim_dev_type.category);
-			dev_info->prim_dev_type.subID =
-				le16_to_cpu(dev_info->prim_dev_type.subID);
+			wdi->prim_dev_type.category =
+				le16_to_cpu(wdi->prim_dev_type.category);
+			wdi->prim_dev_type.subID =
+				le16_to_cpu(wdi->prim_dev_type.subID);
 			last = WLP_ATTR_PRI_DEV_TYPE;
 			used += result;
 			break;
@@ -1098,7 +1098,7 @@ static
 int wlp_parse_d1_frame(struct wlp *wlp, struct sk_buff *skb,
 		       struct wlp_uuid *uuid_e,
 		       enum wlp_wss_sel_mthd *sel_mthd,
-		       struct wlp_device_info *dev_info,
+		       struct wlp_device_info *wdi,
 		       enum wlp_assc_error *assc_err)
 {
 	struct device *dev = &wlp->rc->uwb_dev.dev;
@@ -1123,7 +1123,7 @@ int wlp_parse_d1_frame(struct wlp *wlp, struct sk_buff *skb,
 		goto error_parse;
 	}
 	used += result;
-	result = wlp_get_dev_name(wlp, ptr + used, dev_info->name,
+	result = wlp_get_dev_name(wlp, ptr + used, wdi->name,
 				     len - used);
 	if (result < 0) {
 		dev_err(dev, "WLP: unable to obtain Device Name from D1 "
@@ -1131,7 +1131,7 @@ int wlp_parse_d1_frame(struct wlp *wlp, struct sk_buff *skb,
 		goto error_parse;
 	}
 	used += result;
-	result = wlp_get_variable_info(wlp, ptr + used, dev_info, len - used);
+	result = wlp_get_variable_info(wlp, ptr + used, wdi, len - used);
 	if (result < 0) {
 		dev_err(dev, "WLP: unable to obtain Device Information from "
 			"D1 message.\n");
@@ -1171,15 +1171,15 @@ void wlp_handle_d1_frame(struct work_struct *ws)
 	struct device *dev = &wlp->rc->uwb_dev.dev;
 	struct wlp_uuid uuid_e;
 	enum wlp_wss_sel_mthd sel_mthd = 0;
-	struct wlp_device_info dev_info;
+	struct wlp_device_info wdi;
 	enum wlp_assc_error assc_err;
 	struct sk_buff *resp = NULL;
 
 	/* Parse D1 frame */
 	mutex_lock(&wss->mutex);
 	mutex_lock(&wlp->mutex); /* to access wlp->uuid */
-	memset(&dev_info, 0, sizeof(dev_info));
-	result = wlp_parse_d1_frame(wlp, skb, &uuid_e, &sel_mthd, &dev_info,
+	memset(&wdi, 0, sizeof(wdi));
+	result = wlp_parse_d1_frame(wlp, skb, &uuid_e, &sel_mthd, &wdi,
 				    &assc_err);
 	if (result < 0) {
 		dev_err(dev, "WLP: Unable to parse incoming D1 frame.\n");
diff --git a/drivers/uwb/wlp/sysfs.c b/drivers/uwb/wlp/sysfs.c
index 6627c94..b24751c 100644
--- a/drivers/uwb/wlp/sysfs.c
+++ b/drivers/uwb/wlp/sysfs.c
@@ -333,12 +333,12 @@ ssize_t wlp_dev_##type##_show(struct wlp *wlp, char *buf)		\
 {									\
 	ssize_t result = 0;						\
 	mutex_lock(&wlp->mutex);					\
-	if (wlp->dev_info == NULL) {					\
+	if (wlp->wdi == NULL) {						\
 		result = __wlp_setup_device_info(wlp);			\
 		if (result < 0)						\
 			goto out;					\
 	}								\
-	result = scnprintf(buf, PAGE_SIZE, "%s\n", wlp->dev_info->type);\
+	result = scnprintf(buf, PAGE_SIZE, "%s\n", wlp->wdi->type);	\
 out:									\
 	mutex_unlock(&wlp->mutex);					\
 	return result;							\
@@ -360,14 +360,14 @@ ssize_t wlp_dev_##type##_store(struct wlp *wlp, const char *buf, size_t size)\
 	ssize_t result;							\
 	char format[10];						\
 	mutex_lock(&wlp->mutex);					\
-	if (wlp->dev_info == NULL) {					\
+	if (wlp->wdi == NULL) {						\
 		result = __wlp_alloc_device_info(wlp);			\
 		if (result < 0)						\
 			goto out;					\
 	}								\
-	memset(wlp->dev_info->type, 0, sizeof(wlp->dev_info->type));	\
+	memset(wlp->wdi->type, 0, sizeof(wlp->wdi->type));		\
 	sprintf(format, "%%%uc", len);					\
-	result = sscanf(buf, format, wlp->dev_info->type);		\
+	result = sscanf(buf, format, wlp->wdi->type);			\
 out:									\
 	mutex_unlock(&wlp->mutex);					\
 	return result < 0 ? result : size;				\
@@ -409,13 +409,13 @@ ssize_t wlp_dev_prim_category_show(struct wlp *wlp, char *buf)
 {
 	ssize_t result = 0;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_setup_device_info(wlp);
 		if (result < 0)
 			goto out;
 	}
 	result = scnprintf(buf, PAGE_SIZE, "%s\n",
-		  wlp_dev_category_str(wlp->dev_info->prim_dev_type.category));
+		  wlp_dev_category_str(wlp->wdi->prim_dev_type.category));
 out:
 	mutex_unlock(&wlp->mutex);
 	return result;
@@ -428,7 +428,7 @@ ssize_t wlp_dev_prim_category_store(struct wlp *wlp, const char *buf,
 	ssize_t result;
 	u16 cat;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_alloc_device_info(wlp);
 		if (result < 0)
 			goto out;
@@ -436,7 +436,7 @@ ssize_t wlp_dev_prim_category_store(struct wlp *wlp, const char *buf,
 	result = sscanf(buf, "%hu", &cat);
 	if ((cat >= WLP_DEV_CAT_COMPUTER && cat <= WLP_DEV_CAT_TELEPHONE)
 	    || cat == WLP_DEV_CAT_OTHER)
-		wlp->dev_info->prim_dev_type.category = cat;
+		wlp->wdi->prim_dev_type.category = cat;
 	else
 		result = -EINVAL;
 out:
@@ -449,15 +449,15 @@ ssize_t wlp_dev_prim_OUI_show(struct wlp *wlp, char *buf)
 {
 	ssize_t result = 0;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_setup_device_info(wlp);
 		if (result < 0)
 			goto out;
 	}
 	result = scnprintf(buf, PAGE_SIZE, "%02x:%02x:%02x\n",
-			   wlp->dev_info->prim_dev_type.OUI[0],
-			   wlp->dev_info->prim_dev_type.OUI[1],
-			   wlp->dev_info->prim_dev_type.OUI[2]);
+			   wlp->wdi->prim_dev_type.OUI[0],
+			   wlp->wdi->prim_dev_type.OUI[1],
+			   wlp->wdi->prim_dev_type.OUI[2]);
 out:
 	mutex_unlock(&wlp->mutex);
 	return result;
@@ -469,7 +469,7 @@ ssize_t wlp_dev_prim_OUI_store(struct wlp *wlp, const char *buf, size_t size)
 	ssize_t result;
 	u8 OUI[3];
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_alloc_device_info(wlp);
 		if (result < 0)
 			goto out;
@@ -480,7 +480,7 @@ ssize_t wlp_dev_prim_OUI_store(struct wlp *wlp, const char *buf, size_t size)
 		result = -EINVAL;
 		goto out;
 	} else
-		memcpy(wlp->dev_info->prim_dev_type.OUI, OUI, sizeof(OUI));
+		memcpy(wlp->wdi->prim_dev_type.OUI, OUI, sizeof(OUI));
 out:
 	mutex_unlock(&wlp->mutex);
 	return result < 0 ? result : size;
@@ -492,13 +492,13 @@ ssize_t wlp_dev_prim_OUI_sub_show(struct wlp *wlp, char *buf)
 {
 	ssize_t result = 0;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_setup_device_info(wlp);
 		if (result < 0)
 			goto out;
 	}
 	result = scnprintf(buf, PAGE_SIZE, "%u\n",
-			   wlp->dev_info->prim_dev_type.OUIsubdiv);
+			   wlp->wdi->prim_dev_type.OUIsubdiv);
 out:
 	mutex_unlock(&wlp->mutex);
 	return result;
@@ -512,14 +512,14 @@ ssize_t wlp_dev_prim_OUI_sub_store(struct wlp *wlp, const char *buf,
 	unsigned sub;
 	u8 max_sub = ~0;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_alloc_device_info(wlp);
 		if (result < 0)
 			goto out;
 	}
 	result = sscanf(buf, "%u", &sub);
 	if (sub <= max_sub)
-		wlp->dev_info->prim_dev_type.OUIsubdiv = sub;
+		wlp->wdi->prim_dev_type.OUIsubdiv = sub;
 	else
 		result = -EINVAL;
 out:
@@ -532,13 +532,13 @@ ssize_t wlp_dev_prim_subcat_show(struct wlp *wlp, char *buf)
 {
 	ssize_t result = 0;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_setup_device_info(wlp);
 		if (result < 0)
 			goto out;
 	}
 	result = scnprintf(buf, PAGE_SIZE, "%u\n",
-			   wlp->dev_info->prim_dev_type.subID);
+			   wlp->wdi->prim_dev_type.subID);
 out:
 	mutex_unlock(&wlp->mutex);
 	return result;
@@ -552,14 +552,14 @@ ssize_t wlp_dev_prim_subcat_store(struct wlp *wlp, const char *buf,
 	unsigned sub;
 	__le16 max_sub = ~0;
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info == NULL) {
+	if (wlp->wdi == NULL) {
 		result = __wlp_alloc_device_info(wlp);
 		if (result < 0)
 			goto out;
 	}
 	result = sscanf(buf, "%u", &sub);
 	if (sub <= max_sub)
-		wlp->dev_info->prim_dev_type.subID = sub;
+		wlp->wdi->prim_dev_type.subID = sub;
 	else
 		result = -EINVAL;
 out:
diff --git a/drivers/uwb/wlp/wlp-lc.c b/drivers/uwb/wlp/wlp-lc.c
index 13db739..530613e 100644
--- a/drivers/uwb/wlp/wlp-lc.c
+++ b/drivers/uwb/wlp/wlp-lc.c
@@ -39,9 +39,9 @@ void wlp_neighbor_init(struct wlp_neighbor_e *neighbor)
 int __wlp_alloc_device_info(struct wlp *wlp)
 {
 	struct device *dev = &wlp->rc->uwb_dev.dev;
-	BUG_ON(wlp->dev_info != NULL);
-	wlp->dev_info = kzalloc(sizeof(struct wlp_device_info), GFP_KERNEL);
-	if (wlp->dev_info == NULL) {
+	BUG_ON(wlp->wdi != NULL);
+	wlp->wdi = kzalloc(sizeof(struct wlp_device_info), GFP_KERNEL);
+	if (wlp->wdi == NULL) {
 		dev_err(dev, "WLP: Unable to allocate memory for "
 			"device information.\n");
 		return -ENOMEM;
@@ -58,7 +58,7 @@ int __wlp_alloc_device_info(struct wlp *wlp)
 static
 void __wlp_fill_device_info(struct wlp *wlp)
 {
-	wlp->fill_device_info(wlp, wlp->dev_info);
+	wlp->fill_device_info(wlp, wlp->wdi);
 }
 
 /**
@@ -538,8 +538,8 @@ void wlp_remove(struct wlp *wlp)
 	uwb_notifs_deregister(wlp->rc, &wlp->uwb_notifs_handler);
 	wlp_eda_release(&wlp->eda);
 	mutex_lock(&wlp->mutex);
-	if (wlp->dev_info != NULL)
-		kfree(wlp->dev_info);
+	if (wlp->wdi != NULL)
+		kfree(wlp->wdi);
 	mutex_unlock(&wlp->mutex);
 	wlp->rc = NULL;
 }
-- 
1.7.0.3.311.g6a6955

