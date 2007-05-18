From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 1/4] [Net] Support Xen accelerated network
	plugin modules
Date: Fri, 18 May 2007 14:16:02 +0100
Message-ID: <1179494163.14376.8.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-IwzJRqgSZ0cz4/yLuKrg"
Cc: muli@il.ibm.com, netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org


--=-IwzJRqgSZ0cz4/yLuKrg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Provide two helper functions (xenbus_for_each_frontend,
xenbus_for_each_backend) to allow drivers to iterate the xenbus frontend
and backend buses.

diff -r 4f67d849e788 linux-2.6-xen-
sparse/drivers/xen/xenbus/xenbus_probe.c
--- a/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe.c Tue Apr 03
09:03:51 2007 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe.c Tue Apr 03
13:32:33 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version
2
@@ -1079,3 +1080,10 @@ static int __init boot_wait_for_devices(

late_initcall(boot_wait_for_devices);
#endif
+
+
+int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void
*))
+{
+        return bus_for_each_dev(&xenbus_frontend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_frontend);
diff -r 4f67d849e788 linux-2.6-xen-
sparse/drivers/xen/xenbus/xenbus_probe_backend.c
--- a/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe_backend.c Tue
Apr 03 09:03:51 2007 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe_backend.c Tue
Apr 03 13:32:33 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version
2
@@ -284,3 +285,10 @@ void xenbus_backend_device_register(void
       xenbus_backend.error);
}
}
+
+int xenbus_for_each_backend(void *arg, int (*fn)(struct device *, void
*))
+{
+        return bus_for_each_dev(&xenbus_backend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_backend);
+
diff -r 4f67d849e788 linux-2.6-xen-sparse/include/xen/xenbus.h
--- a/linux-2.6-xen-sparse/include/xen/xenbus.h Tue Apr 03 09:03:51 2007
+0100
+++ b/linux-2.6-xen-sparse/include/xen/xenbus.h Tue Apr 03 13:32:33 2007
+0100
@@ -299,4 +299,7 @@ int xenbus_dev_is_online(struct xenbus_d
int xenbus_dev_is_online(struct xenbus_device *dev);
int xenbus_frontend_closed(struct xenbus_device *dev);

+extern int xenbus_for_each_backend(void *arg, int (*fn)(struct device
*, void *));
+extern int xenbus_for_each_frontend(void *arg, int (*fn)(struct device
*, void *));
+
#endif /* _XEN_XENBUS_H */


--=-IwzJRqgSZ0cz4/yLuKrg
Content-Disposition: attachment; filename=xenbus_for_each
Content-Type: text/plain; name=xenbus_for_each; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add xenbus_for_each_[back,front]end functions to iterate each bus

diff -r 4f67d849e788 linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe.c
--- a/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe.c	Tue Apr 03 09:03:51 2007 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe.c	Tue Apr 03 13:32:33 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -1079,3 +1080,10 @@ static int __init boot_wait_for_devices(
 
 late_initcall(boot_wait_for_devices);
 #endif
+
+
+int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void *))
+{
+        return bus_for_each_dev(&xenbus_frontend.bus, NULL, arg, fn);
+}
+EXPORT_SYMBOL_GPL(xenbus_for_each_frontend);
diff -r 4f67d849e788 linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe_backend.c
--- a/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe_backend.c	Tue Apr 03 09:03:51 2007 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/xenbus/xenbus_probe_backend.c	Tue Apr 03 13:32:33 2007 +0100
@@ -4,6 +4,7 @@
  * Copyright (C) 2005 Rusty Russell, IBM Corporation
  * Copyright (C) 2005 Mike Wray, Hewlett-Packard
  * Copyright (C) 2005, 2006 XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  * 
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -284,3 +285,10 @@ void xenbus_backend_device_register(void
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
diff -r 4f67d849e788 linux-2.6-xen-sparse/include/xen/xenbus.h
--- a/linux-2.6-xen-sparse/include/xen/xenbus.h	Tue Apr 03 09:03:51 2007 +0100
+++ b/linux-2.6-xen-sparse/include/xen/xenbus.h	Tue Apr 03 13:32:33 2007 +0100
@@ -299,4 +299,7 @@ int xenbus_dev_is_online(struct xenbus_d
 int xenbus_dev_is_online(struct xenbus_device *dev);
 int xenbus_frontend_closed(struct xenbus_device *dev);
 
+extern int xenbus_for_each_backend(void *arg, int (*fn)(struct device *, void *));
+extern int xenbus_for_each_frontend(void *arg, int (*fn)(struct device *, void *));
+
 #endif /* _XEN_XENBUS_H */

--=-IwzJRqgSZ0cz4/yLuKrg
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xensource.com
http://lists.xensource.com/xen-devel

--=-IwzJRqgSZ0cz4/yLuKrg--
