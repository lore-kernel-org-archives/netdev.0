From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 1/4] [Net] Support accelerated network plugin modules
Date: Fri, 15 Jun 2007 11:46:25 +0100
Message-ID: <1181904385.4121.52.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6GRXeU4lBRFyK1AX4n0Z"
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:8420 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751159AbXFOKq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 06:46:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6GRXeU4lBRFyK1AX4n0Z
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add xenbus_for_each_[back,front]end functions to iterate each bus

Signed-off-by: Kieran Mansley <kmansley@solarflare.com> 

diff -r d5e0eb7dd069 drivers/xen/xenbus/xenbus_probe.c
--- a/drivers/xen/xenbus/xenbus_probe.c	Sun Jun 10 19:50:32 2007 +0100
+++ b/drivers/xen/xenbus/xenbus_probe.c	Thu Jun 14 14:49:40 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -1085,3 +1086,10 @@ static int __init boot_wait_for_devices(
 
 late_initcall(boot_wait_for_devices);
 #endif
+
+
+int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void *))
+{
+        return bus_for_each_dev(&xenbus_frontend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_frontend);
diff -r d5e0eb7dd069 drivers/xen/xenbus/xenbus_probe_backend.c
--- a/drivers/xen/xenbus/xenbus_probe_backend.c	Sun Jun 10 19:50:32 2007 +0100
+++ b/drivers/xen/xenbus/xenbus_probe_backend.c	Thu Jun 14 14:49:40 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -285,3 +286,10 @@ void xenbus_backend_device_register(void
 		       xenbus_backend.error);
 	}
 }
+
+int xenbus_for_each_backend(void *arg, int (*fn)(struct device *, void *))
+{
+        return bus_for_each_dev(&xenbus_backend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_backend);
+
diff -r d5e0eb7dd069 include/xen/xenbus.h
--- a/include/xen/xenbus.h	Sun Jun 10 19:50:32 2007 +0100
+++ b/include/xen/xenbus.h	Thu Jun 14 14:49:40 2007 +0100
@@ -299,4 +299,7 @@ int xenbus_dev_is_online(struct xenbus_d
 int xenbus_dev_is_online(struct xenbus_device *dev);
 int xenbus_frontend_closed(struct xenbus_device *dev);
 
+extern int xenbus_for_each_backend(void *arg, int (*fn)(struct device *, void *));
+extern int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void *));
+
 #endif /* _XEN_XENBUS_H */


--=-6GRXeU4lBRFyK1AX4n0Z
Content-Disposition: attachment; filename=xenbus_for_each
Content-Type: text/plain; name=xenbus_for_each; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add xenbus_for_each_[back,front]end functions to iterate each bus

diff -r d5e0eb7dd069 drivers/xen/xenbus/xenbus_probe.c
--- a/drivers/xen/xenbus/xenbus_probe.c	Sun Jun 10 19:50:32 2007 +0100
+++ b/drivers/xen/xenbus/xenbus_probe.c	Thu Jun 14 14:49:40 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -1085,3 +1086,10 @@ static int __init boot_wait_for_devices(
 
 late_initcall(boot_wait_for_devices);
 #endif
+
+
+int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void *))
+{
+        return bus_for_each_dev(&xenbus_frontend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_frontend);
diff -r d5e0eb7dd069 drivers/xen/xenbus/xenbus_probe_backend.c
--- a/drivers/xen/xenbus/xenbus_probe_backend.c	Sun Jun 10 19:50:32 2007 +0100
+++ b/drivers/xen/xenbus/xenbus_probe_backend.c	Thu Jun 14 14:49:40 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -285,3 +286,10 @@ void xenbus_backend_device_register(void
 		       xenbus_backend.error);
 	}
 }
+
+int xenbus_for_each_backend(void *arg, int (*fn)(struct device *, void *))
+{
+        return bus_for_each_dev(&xenbus_backend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_backend);
+
diff -r d5e0eb7dd069 include/xen/xenbus.h
--- a/include/xen/xenbus.h	Sun Jun 10 19:50:32 2007 +0100
+++ b/include/xen/xenbus.h	Thu Jun 14 14:49:40 2007 +0100
@@ -299,4 +299,7 @@ int xenbus_dev_is_online(struct xenbus_d
 int xenbus_dev_is_online(struct xenbus_device *dev);
 int xenbus_frontend_closed(struct xenbus_device *dev);
 
+extern int xenbus_for_each_backend(void *arg, int (*fn)(struct device *, void *));
+extern int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void *));
+
 #endif /* _XEN_XENBUS_H */

--=-6GRXeU4lBRFyK1AX4n0Z--

