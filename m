From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth: Convert to net_device_ops
Date: Mon, 23 Mar 2009 11:17:39 +0100
Message-ID: <OF2EE08546.DF677136-ONC1257582.0037C87E-C1257582.00388BCE@transmode.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 00388BC7C1257582_="
To: leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:53617 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbZCWKRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 06:17:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 00388BC7C1257582_=
Content-Type: text/plain; charset="US-ASCII"

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

Sorry for the WS damaged patch, but my current company mailer cannot
handle inline patches. Due to this we are setting up a new mail system
but it will be a few days before this is ready.
Therefore I am attaching this patch as well, use that one
to apply instaed of the inline variant.


 drivers/net/ucc_geth.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e5c3d..d3f6eee 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3503,6 +3503,24 @@ static phy_interface_t to_phy_interface(const char 
*phy_connection_type)
        return PHY_INTERFACE_MODE_MII;
 }
 
+static const struct net_device_ops ucc_geth_netdev_ops = {
+       .ndo_open               = ucc_geth_open,
+       .ndo_stop               = ucc_geth_close,
+       .ndo_start_xmit         = ucc_geth_start_xmit,
+       .ndo_validate_addr      = eth_validate_addr,
+       .ndo_set_multicast_list = ucc_geth_set_multi,
+#if 0
+/* not yet */
+       .ndo_set_mac_address    = ucc_geth_set_mac_address,
+       .ndo_change_mtu         = ucc_geth_change_mtu,
+       .ndo_do_ioctl           = ucc_geth_do_ioctl,
+#endif
+       .ndo_tx_timeout         = ucc_geth_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+       .ndo_poll_controller    = ucc_netpoll,
+#endif
+};
+
 static int ucc_geth_probe(struct of_device* ofdev, const struct 
of_device_id *match)
 {
        struct device *device = &ofdev->dev;
@@ -3715,19 +3733,11 @@ static int ucc_geth_probe(struct of_device* ofdev, 
const struct of_device_id *ma
 
        /* Fill in the dev structure */
        uec_set_ethtool_ops(dev);
-       dev->open = ucc_geth_open;
-       dev->hard_start_xmit = ucc_geth_start_xmit;
-       dev->tx_timeout = ucc_geth_timeout;
+       dev->netdev_ops = &ucc_geth_netdev_ops;
        dev->watchdog_timeo = TX_TIMEOUT;
        INIT_WORK(&ugeth->timeout_work, ucc_geth_timeout_work);
        netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, 
UCC_GETH_DEV_WEIGHT);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-       dev->poll_controller = ucc_netpoll;
-#endif
-       dev->stop = ucc_geth_close;
-//    dev->change_mtu = ucc_geth_change_mtu;
        dev->mtu = 1500;
-       dev->set_multicast_list = ucc_geth_set_multi;
 
        ugeth->msg_enable = netif_msg_init(debug.msg_enable, 
UGETH_MSG_DEFAULT);
        ugeth->phy_interface = phy_interface;
-- 
1.6.1.3
--=_mixed 00388BC7C1257582_=
Content-Type: application/octet-stream; name="0001-ucc_geth-Convert-to-net_device_ops.patch"
Content-Disposition: attachment; filename="0001-ucc_geth-Convert-to-net_device_ops.patch"
Content-Transfer-Encoding: base64

RnJvbSBhOTJjMzg5YmE5Y2Q3ZWI2NzRiZmE1ODg4MmRkYzVmZGY5M2UxMWQwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb2FraW0gVGplcm5sdW5kIDxKb2FraW0uVGplcm5sdW5kQHRy
YW5zbW9kZS5zZT4KRGF0ZTogRnJpLCAyMCBNYXIgMjAwOSAyMTowOToxNCArMDEwMApTdWJqZWN0
OiBbUEFUQ0hdIHVjY19nZXRoOiBDb252ZXJ0IHRvIG5ldF9kZXZpY2Vfb3BzCgoKU2lnbmVkLW9m
Zi1ieTogSm9ha2ltIFRqZXJubHVuZCA8Sm9ha2ltLlRqZXJubHVuZEB0cmFuc21vZGUuc2U+Ci0t
LQogZHJpdmVycy9uZXQvdWNjX2dldGguYyB8ICAgMjggKysrKysrKysrKysrKysrKysrKy0tLS0t
LS0tLQogMSBmaWxlcyBjaGFuZ2VkLCAxOSBpbnNlcnRpb25zKCspLCA5IGRlbGV0aW9ucygtKQoK
ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3VjY19nZXRoLmMgYi9kcml2ZXJzL25ldC91Y2NfZ2V0
aC5jCmluZGV4IDEyZTVjM2QuLmQzZjZlZWUgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3VjY19n
ZXRoLmMKKysrIGIvZHJpdmVycy9uZXQvdWNjX2dldGguYwpAQCAtMzUwMyw2ICszNTAzLDI0IEBA
IHN0YXRpYyBwaHlfaW50ZXJmYWNlX3QgdG9fcGh5X2ludGVyZmFjZShjb25zdCBjaGFyICpwaHlf
Y29ubmVjdGlvbl90eXBlKQogCXJldHVybiBQSFlfSU5URVJGQUNFX01PREVfTUlJOwogfQogCitz
dGF0aWMgY29uc3Qgc3RydWN0IG5ldF9kZXZpY2Vfb3BzIHVjY19nZXRoX25ldGRldl9vcHMgPSB7
CisJLm5kb19vcGVuCQk9IHVjY19nZXRoX29wZW4sCisJLm5kb19zdG9wCQk9IHVjY19nZXRoX2Ns
b3NlLAorCS5uZG9fc3RhcnRfeG1pdAkJPSB1Y2NfZ2V0aF9zdGFydF94bWl0LAorCS5uZG9fdmFs
aWRhdGVfYWRkcgk9IGV0aF92YWxpZGF0ZV9hZGRyLAorCS5uZG9fc2V0X211bHRpY2FzdF9saXN0
CT0gdWNjX2dldGhfc2V0X211bHRpLAorI2lmIDAKKy8qIG5vdCB5ZXQgKi8KKwkubmRvX3NldF9t
YWNfYWRkcmVzcwk9IHVjY19nZXRoX3NldF9tYWNfYWRkcmVzcywKKwkubmRvX2NoYW5nZV9tdHUJ
CT0gdWNjX2dldGhfY2hhbmdlX210dSwKKwkubmRvX2RvX2lvY3RsCQk9IHVjY19nZXRoX2RvX2lv
Y3RsLAorI2VuZGlmCisJLm5kb190eF90aW1lb3V0CQk9IHVjY19nZXRoX3RpbWVvdXQsCisjaWZk
ZWYgQ09ORklHX05FVF9QT0xMX0NPTlRST0xMRVIKKwkubmRvX3BvbGxfY29udHJvbGxlcgk9IHVj
Y19uZXRwb2xsLAorI2VuZGlmCit9OworCiBzdGF0aWMgaW50IHVjY19nZXRoX3Byb2JlKHN0cnVj
dCBvZl9kZXZpY2UqIG9mZGV2LCBjb25zdCBzdHJ1Y3Qgb2ZfZGV2aWNlX2lkICptYXRjaCkKIHsK
IAlzdHJ1Y3QgZGV2aWNlICpkZXZpY2UgPSAmb2ZkZXYtPmRldjsKQEAgLTM3MTUsMTkgKzM3MzMs
MTEgQEAgc3RhdGljIGludCB1Y2NfZ2V0aF9wcm9iZShzdHJ1Y3Qgb2ZfZGV2aWNlKiBvZmRldiwg
Y29uc3Qgc3RydWN0IG9mX2RldmljZV9pZCAqbWEKIAogCS8qIEZpbGwgaW4gdGhlIGRldiBzdHJ1
Y3R1cmUgKi8KIAl1ZWNfc2V0X2V0aHRvb2xfb3BzKGRldik7Ci0JZGV2LT5vcGVuID0gdWNjX2dl
dGhfb3BlbjsKLQlkZXYtPmhhcmRfc3RhcnRfeG1pdCA9IHVjY19nZXRoX3N0YXJ0X3htaXQ7Ci0J
ZGV2LT50eF90aW1lb3V0ID0gdWNjX2dldGhfdGltZW91dDsKKwlkZXYtPm5ldGRldl9vcHMgPSAm
dWNjX2dldGhfbmV0ZGV2X29wczsKIAlkZXYtPndhdGNoZG9nX3RpbWVvID0gVFhfVElNRU9VVDsK
IAlJTklUX1dPUksoJnVnZXRoLT50aW1lb3V0X3dvcmssIHVjY19nZXRoX3RpbWVvdXRfd29yayk7
CiAJbmV0aWZfbmFwaV9hZGQoZGV2LCAmdWdldGgtPm5hcGksIHVjY19nZXRoX3BvbGwsIFVDQ19H
RVRIX0RFVl9XRUlHSFQpOwotI2lmZGVmIENPTkZJR19ORVRfUE9MTF9DT05UUk9MTEVSCi0JZGV2
LT5wb2xsX2NvbnRyb2xsZXIgPSB1Y2NfbmV0cG9sbDsKLSNlbmRpZgotCWRldi0+c3RvcCA9IHVj
Y19nZXRoX2Nsb3NlOwotLy8gICAgZGV2LT5jaGFuZ2VfbXR1ID0gdWNjX2dldGhfY2hhbmdlX210
dTsKIAlkZXYtPm10dSA9IDE1MDA7Ci0JZGV2LT5zZXRfbXVsdGljYXN0X2xpc3QgPSB1Y2NfZ2V0
aF9zZXRfbXVsdGk7CiAKIAl1Z2V0aC0+bXNnX2VuYWJsZSA9IG5ldGlmX21zZ19pbml0KGRlYnVn
Lm1zZ19lbmFibGUsIFVHRVRIX01TR19ERUZBVUxUKTsKIAl1Z2V0aC0+cGh5X2ludGVyZmFjZSA9
IHBoeV9pbnRlcmZhY2U7Ci0tIAoxLjYuMS4zCgo=

--=_mixed 00388BC7C1257582_=--
