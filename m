From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: 2 bugs found in Cisco vpnclient-4.8.02.0030
Date: Tue, 09 Sep 2008 14:11:25 +0200
Message-ID: <48C667ED.9060206@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040607010905010605050706"
Cc: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?ISO-8859-1?Q?N=E9meth_Tam=E1s?= <nice-OZwXound/Z2+mM1/5BeW/g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040607010905010605050706
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Tamas,
I've got the vpn client going over ethernet but not yet over the hso device.
I found 2 idiotic substantial bugs in the vpn client one which caused
the crash in linuxcniapi.c as you were seeing
You'll note that in some places the code was looping to <MAX_INTERFACES
& other places to <=MAX_INTERFACES, this was flying over the edge
of the array.
These bugs are not unique to the hso driver they just happened to
manifest there.

Let me know if you still find crashes somehow, post them to me & more importantly
let me know if you get hso going over vpn.

Please find some way to get the bugfixes back to Cisco.

-- 
best regards,
D.J. Barrow

--------------040607010905010605050706
Content-Type: text/x-diff;
 name="vpnclient.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vpnclient.patch"

--- cisco-vpn-client.orig/vpnclient-4.8.02.0030/interceptor.c	2008-06-23 18:59:12.000000000 +0200
+++ cisco-vpn-client/vpnclient-4.8.02.0030/interceptor.c	2008-09-09 13:54:02.000000000 +0200
@@ -502,7 +502,7 @@
 {
     int i;
     
-    for (i=0; i <= MAX_INTERFACES; i++)
+    for (i=0; i < MAX_INTERFACES; i++)
     {
         BINDING *b = &Bindings[i];
         if (b->pDevice && (dev->ifindex == b->pDevice->ifindex))
--- cisco-vpn-client.orig/vpnclient-4.8.02.0030/linuxcniapi.c	2008-06-23 18:59:12.000000000 +0200
+++ cisco-vpn-client/vpnclient-4.8.02.0030/linuxcniapi.c	2008-09-09 13:37:33.000000000 +0200
@@ -577,7 +577,7 @@
 {
     int i;
     
-    for (i=0; i <= MAX_INTERFACES; i++)
+    for (i=0; i < MAX_INTERFACES; i++)
     {
         BINDING *b = &Bindings[i];
         if (b->pDevice && (iIndex == b->pDevice->ifindex))

--------------040607010905010605050706--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
