From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 1/2] device property: Add ETH_ALEN check, update comments.
Date: Wed, 19 Aug 2015 11:46:42 -0500
Message-ID: <1440002803-5113-2-git-send-email-jeremy.linton@arm.com>
References: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: gregkh@linuxfoundation.org, steve.glendinning@shawell.net,
	linux@roeck-us.net, jeremy.linton@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:12183 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751582AbbHSQrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:47:32 -0400
In-Reply-To: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds MAC address length check back into
the device_get_mac_addr() function before calling
is_valid_ether_addr() similar to the way the OF
routine does it.

Update the comments for the two new functions.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/base/property.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index 2e8cd14..4c20828 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -537,7 +537,7 @@ bool device_dma_is_coherent(struct device *dev)
 EXPORT_SYMBOL_GPL(device_dma_is_coherent);
=20
 /**
- * device_get_phy_mode - Get phy mode for given device_node
+ * device_get_phy_mode - Get phy mode for given device
  * @dev:=09Pointer to the given device
  *
  * The function gets phy interface string from property 'phy-mode' or
@@ -570,13 +570,18 @@ static void *device_get_mac_addr(struct device *dev,
 {
 =09int ret =3D device_property_read_u8_array(dev, name, addr, alen);
=20
-=09if (ret =3D=3D 0 && is_valid_ether_addr(addr))
+=09if (ret =3D=3D 0 && alen =3D=3D ETH_ALEN && is_valid_ether_addr(addr))
 =09=09return addr;
 =09return NULL;
 }
=20
 /**
- * Search the device tree for the best MAC address to use.  'mac-address' =
is
+ * device_get_mac_address - Get the MAC for a given device
+ * @dev:=09Pointer to the device
+ * @addr:=09Address of buffer to store the MAC in
+ * @alen:=09Length of the buffer pointed to by addr, should be ETH_ALEN
+ *
+ * Search the firmware node for the best MAC address to use.  'mac-address=
' is
  * checked first, because that is supposed to contain to "most recent" MAC
  * address. If that isn't set, then 'local-mac-address' is checked next,
  * because that is the default address.  If that isn't set, then the obsol=
ete
@@ -587,11 +592,11 @@ static void *device_get_mac_addr(struct device *dev,
  * MAC address.
  *
  * All-zero MAC addresses are rejected, because those could be properties =
that
- * exist in the device tree, but were not set by U-Boot.  For example, the
- * DTS could define 'mac-address' and 'local-mac-address', with zero MAC
- * addresses.  Some older U-Boots only initialized 'local-mac-address'.  I=
n
- * this case, the real MAC is in 'local-mac-address', and 'mac-address' ex=
ists
- * but is all zeros.
+ * exist in the firmware tables, but were not updated by the firmware.  Fo=
r
+ * example, the DTS could define 'mac-address' and 'local-mac-address', wi=
th
+ * zero MAC addresses.  Some older U-Boots only initialized 'local-mac-add=
ress'.
+ * In this case, the real MAC is in 'local-mac-address', and 'mac-address'
+ * exists but is all zeros.
 */
 void *device_get_mac_address(struct device *dev, char *addr, int alen)
 {
--=20
2.4.3
