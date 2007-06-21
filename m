From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 2/4] [Net] Support accelerated network plugin modules
Date: Thu, 21 Jun 2007 14:17:20 +0100
Message-ID: <1182431840.5614.40.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ftbp8svm2bnYbiNLNvEJ"
Cc: netdev@vger.kernel.org
To: xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:15731 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754406AbXFUNRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 09:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ftbp8svm2bnYbiNLNvEJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add accel option to vif xend config

Signed-off-by: Kieran Mansley <kmansley@solarflare.com> 

diff -r 405eb3e22887 tools/python/xen/xend/server/netif.py
--- a/tools/python/xen/xend/server/netif.py	Thu Jun 14 14:50:04 2007 +0100
+++ b/tools/python/xen/xend/server/netif.py	Thu Jun 14 14:52:55 2007 +0100
@@ -107,6 +107,7 @@ class NetifController(DevController):
         uuid    = config.get('uuid')
         ipaddr  = config.get('ip')
         model   = config.get('model')
+        accel   = config.get('accel')
 
         if not typ:
             typ = xoptions.netback_type
@@ -131,6 +132,8 @@ class NetifController(DevController):
             back['uuid'] = uuid
         if model:
             back['model'] = model
+        if accel:
+            back['accel'] = accel
 
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         for x in back:
@@ -157,10 +160,10 @@ class NetifController(DevController):
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         devinfo = ()
         for x in ( 'script', 'ip', 'bridge', 'mac',
-                   'type', 'vifname', 'rate', 'uuid', 'model' ):
+                   'type', 'vifname', 'rate', 'uuid', 'model', 'accel'):
             y = self.vm._readVm(config_path + x)
             devinfo += (y,)
-        (script, ip, bridge, mac, typ, vifname, rate, uuid, model) = devinfo
+        (script, ip, bridge, mac, typ, vifname, rate, uuid, model, accel) = devinfo
 
         if script:
             result['script'] = script
@@ -180,5 +183,7 @@ class NetifController(DevController):
             result['uuid'] = uuid
         if model:
             result['model'] = model
+        if accel:
+            result['accel'] = accel
             
         return result
diff -r 405eb3e22887 tools/python/xen/xm/create.py
--- a/tools/python/xen/xm/create.py	Thu Jun 14 14:50:04 2007 +0100
+++ b/tools/python/xen/xm/create.py	Thu Jun 14 14:52:55 2007 +0100
@@ -710,7 +710,7 @@ def configure_vifs(config_devs, vals):
 
         def f(k):
             if k not in ['backend', 'bridge', 'ip', 'mac', 'script', 'type',
-                         'vifname', 'rate', 'model']:
+                         'vifname', 'rate', 'model', 'accel']:
                 err('Invalid vif option: ' + k)
 
             config_vif.append([k, d[k]])


--=-ftbp8svm2bnYbiNLNvEJ
Content-Disposition: attachment; filename=accel_vif_xend
Content-Type: text/plain; name=accel_vif_xend; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add accel option to vif xend config

diff -r 405eb3e22887 tools/python/xen/xend/server/netif.py
--- a/tools/python/xen/xend/server/netif.py	Thu Jun 14 14:50:04 2007 +0100
+++ b/tools/python/xen/xend/server/netif.py	Thu Jun 14 14:52:55 2007 +0100
@@ -107,6 +107,7 @@ class NetifController(DevController):
         uuid    = config.get('uuid')
         ipaddr  = config.get('ip')
         model   = config.get('model')
+        accel   = config.get('accel')
 
         if not typ:
             typ = xoptions.netback_type
@@ -131,6 +132,8 @@ class NetifController(DevController):
             back['uuid'] = uuid
         if model:
             back['model'] = model
+        if accel:
+            back['accel'] = accel
 
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         for x in back:
@@ -157,10 +160,10 @@ class NetifController(DevController):
         config_path = "device/%s/%d/" % (self.deviceClass, devid)
         devinfo = ()
         for x in ( 'script', 'ip', 'bridge', 'mac',
-                   'type', 'vifname', 'rate', 'uuid', 'model' ):
+                   'type', 'vifname', 'rate', 'uuid', 'model', 'accel'):
             y = self.vm._readVm(config_path + x)
             devinfo += (y,)
-        (script, ip, bridge, mac, typ, vifname, rate, uuid, model) = devinfo
+        (script, ip, bridge, mac, typ, vifname, rate, uuid, model, accel) = devinfo
 
         if script:
             result['script'] = script
@@ -180,5 +183,7 @@ class NetifController(DevController):
             result['uuid'] = uuid
         if model:
             result['model'] = model
+        if accel:
+            result['accel'] = accel
             
         return result
diff -r 405eb3e22887 tools/python/xen/xm/create.py
--- a/tools/python/xen/xm/create.py	Thu Jun 14 14:50:04 2007 +0100
+++ b/tools/python/xen/xm/create.py	Thu Jun 14 14:52:55 2007 +0100
@@ -710,7 +710,7 @@ def configure_vifs(config_devs, vals):
 
         def f(k):
             if k not in ['backend', 'bridge', 'ip', 'mac', 'script', 'type',
-                         'vifname', 'rate', 'model']:
+                         'vifname', 'rate', 'model', 'accel']:
                 err('Invalid vif option: ' + k)
 
             config_vif.append([k, d[k]])

--=-ftbp8svm2bnYbiNLNvEJ--

