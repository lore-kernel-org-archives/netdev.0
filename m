From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Wed, 25 Mar 2009 00:08:53 +0100
Message-ID: <OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se>
References: <OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se>	<20090324.142209.234280606.davem@davemloft.net>
	<OF603BDF0B.B740DD77-ONC1257583.007CAD9B-C1257583.007CFD35@transmode.se>
	<20090324.154902.206324978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 007F2801C1257583_="
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090324.154902.206324978.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--=_mixed 007F2801C1257583_=
Content-Type: text/plain; charset="US-ASCII"

David Miller <davem@davemloft.net> wrote on 24/03/2009 23:49:02:
> 
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Tue, 24 Mar 2009 23:45:13 +0100
> 
> > I don't follow. Are these mandatory now? They were not in the old
> > impl. either.
> 
> See ether_setup() which is called indirectly via alloc_etherdev().
> 
> Yawn...

Same here, getting tiered. Should have seen that. Here goes,
attatched as well as explained earlier.

    Jocke
>From 651fcd7d1ba494f2e2f20da51196b1b3dccdcd68 Mon Sep 17 00:00:00 2001
From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Fri, 20 Mar 2009 21:09:14 +0100
Subject: [PATCH] ucc_geth: Convert to net_device_ops

---
 drivers/net/ucc_geth.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7716239..097aed8 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3501,6 +3501,20 @@ static phy_interface_t to_phy_interface(const char 
*phy_connection_type)
        return PHY_INTERFACE_MODE_MII;
 }
 
+static const struct net_device_ops ucc_geth_netdev_ops = {
+       .ndo_open               = ucc_geth_open,
+       .ndo_stop               = ucc_geth_close,
+       .ndo_start_xmit         = ucc_geth_start_xmit,
+       .ndo_validate_addr      = eth_validate_addr,
+       .ndo_set_mac_address    = eth_mac_addr,
+       .ndo_change_mtu         = eth_change_mtu,
+       .ndo_set_multicast_list = ucc_geth_set_multi,
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
@@ -3716,19 +3730,11 @@ static int ucc_geth_probe(struct of_device* ofdev, 
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


--=_mixed 007F2801C1257583_=
Content-Type: application/octet-stream; name="0001-ucc_geth-Convert-to-net_device_ops.patch"
Content-Disposition: attachment; filename="0001-ucc_geth-Convert-to-net_device_ops.patch"
Content-Transfer-Encoding: base64

RnJvbSA2NTFmY2Q3ZDFiYTQ5NGYyZTJmMjBkYTUxMTk2YjFiM2RjY2RjZDY4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb2FraW0gVGplcm5sdW5kIDxKb2FraW0uVGplcm5sdW5kQHRy
YW5zbW9kZS5zZT4KRGF0ZTogRnJpLCAyMCBNYXIgMjAwOSAyMTowOToxNCArMDEwMApTdWJqZWN0
OiBbUEFUQ0hdIHVjY19nZXRoOiBDb252ZXJ0IHRvIG5ldF9kZXZpY2Vfb3BzCgotLS0KIGRyaXZl
cnMvbmV0L3VjY19nZXRoLmMgfCAgIDI0ICsrKysrKysrKysrKysrKy0tLS0tLS0tLQogMSBmaWxl
cyBjaGFuZ2VkLCAxNSBpbnNlcnRpb25zKCspLCA5IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBh
L2RyaXZlcnMvbmV0L3VjY19nZXRoLmMgYi9kcml2ZXJzL25ldC91Y2NfZ2V0aC5jCmluZGV4IDc3
MTYyMzkuLjA5N2FlZDggMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3VjY19nZXRoLmMKKysrIGIv
ZHJpdmVycy9uZXQvdWNjX2dldGguYwpAQCAtMzUwMSw2ICszNTAxLDIwIEBAIHN0YXRpYyBwaHlf
aW50ZXJmYWNlX3QgdG9fcGh5X2ludGVyZmFjZShjb25zdCBjaGFyICpwaHlfY29ubmVjdGlvbl90
eXBlKQogCXJldHVybiBQSFlfSU5URVJGQUNFX01PREVfTUlJOwogfQogCitzdGF0aWMgY29uc3Qg
c3RydWN0IG5ldF9kZXZpY2Vfb3BzIHVjY19nZXRoX25ldGRldl9vcHMgPSB7CisJLm5kb19vcGVu
CQk9IHVjY19nZXRoX29wZW4sCisJLm5kb19zdG9wCQk9IHVjY19nZXRoX2Nsb3NlLAorCS5uZG9f
c3RhcnRfeG1pdAkJPSB1Y2NfZ2V0aF9zdGFydF94bWl0LAorCS5uZG9fdmFsaWRhdGVfYWRkcgk9
IGV0aF92YWxpZGF0ZV9hZGRyLAorCS5uZG9fc2V0X21hY19hZGRyZXNzCT0gZXRoX21hY19hZGRy
LAorCS5uZG9fY2hhbmdlX210dQkJPSBldGhfY2hhbmdlX210dSwKKwkubmRvX3NldF9tdWx0aWNh
c3RfbGlzdAk9IHVjY19nZXRoX3NldF9tdWx0aSwKKwkubmRvX3R4X3RpbWVvdXQJCT0gdWNjX2dl
dGhfdGltZW91dCwKKyNpZmRlZiBDT05GSUdfTkVUX1BPTExfQ09OVFJPTExFUgorCS5uZG9fcG9s
bF9jb250cm9sbGVyCT0gdWNjX25ldHBvbGwsCisjZW5kaWYKK307CisKIHN0YXRpYyBpbnQgdWNj
X2dldGhfcHJvYmUoc3RydWN0IG9mX2RldmljZSogb2ZkZXYsIGNvbnN0IHN0cnVjdCBvZl9kZXZp
Y2VfaWQgKm1hdGNoKQogewogCXN0cnVjdCBkZXZpY2UgKmRldmljZSA9ICZvZmRldi0+ZGV2OwpA
QCAtMzcxNiwxOSArMzczMCwxMSBAQCBzdGF0aWMgaW50IHVjY19nZXRoX3Byb2JlKHN0cnVjdCBv
Zl9kZXZpY2UqIG9mZGV2LCBjb25zdCBzdHJ1Y3Qgb2ZfZGV2aWNlX2lkICptYQogCiAJLyogRmls
bCBpbiB0aGUgZGV2IHN0cnVjdHVyZSAqLwogCXVlY19zZXRfZXRodG9vbF9vcHMoZGV2KTsKLQlk
ZXYtPm9wZW4gPSB1Y2NfZ2V0aF9vcGVuOwotCWRldi0+aGFyZF9zdGFydF94bWl0ID0gdWNjX2dl
dGhfc3RhcnRfeG1pdDsKLQlkZXYtPnR4X3RpbWVvdXQgPSB1Y2NfZ2V0aF90aW1lb3V0OworCWRl
di0+bmV0ZGV2X29wcyA9ICZ1Y2NfZ2V0aF9uZXRkZXZfb3BzOwogCWRldi0+d2F0Y2hkb2dfdGlt
ZW8gPSBUWF9USU1FT1VUOwogCUlOSVRfV09SSygmdWdldGgtPnRpbWVvdXRfd29yaywgdWNjX2dl
dGhfdGltZW91dF93b3JrKTsKIAluZXRpZl9uYXBpX2FkZChkZXYsICZ1Z2V0aC0+bmFwaSwgdWNj
X2dldGhfcG9sbCwgVUNDX0dFVEhfREVWX1dFSUdIVCk7Ci0jaWZkZWYgQ09ORklHX05FVF9QT0xM
X0NPTlRST0xMRVIKLQlkZXYtPnBvbGxfY29udHJvbGxlciA9IHVjY19uZXRwb2xsOwotI2VuZGlm
Ci0JZGV2LT5zdG9wID0gdWNjX2dldGhfY2xvc2U7Ci0vLyAgICBkZXYtPmNoYW5nZV9tdHUgPSB1
Y2NfZ2V0aF9jaGFuZ2VfbXR1OwogCWRldi0+bXR1ID0gMTUwMDsKLQlkZXYtPnNldF9tdWx0aWNh
c3RfbGlzdCA9IHVjY19nZXRoX3NldF9tdWx0aTsKIAogCXVnZXRoLT5tc2dfZW5hYmxlID0gbmV0
aWZfbXNnX2luaXQoZGVidWcubXNnX2VuYWJsZSwgVUdFVEhfTVNHX0RFRkFVTFQpOwogCXVnZXRo
LT5waHlfaW50ZXJmYWNlID0gcGh5X2ludGVyZmFjZTsKLS0gCjEuNi4xLjMKCg==

--=_mixed 007F2801C1257583_=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--=_mixed 007F2801C1257583_=--
