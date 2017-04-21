From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: [RFC] change the default Kconfig value of mlx5_en
Date: Fri, 21 Apr 2017 21:45:00 +0200
Message-ID: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113c05a881ab22054db27f5a
To: saeedm@mellanox.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34180 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425487AbdDUTpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:45:24 -0400
Received: by mail-lf0-f68.google.com with SMTP id x72so10595920lfb.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:45:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113c05a881ab22054db27f5a
Content-Type: text/plain; charset=UTF-8

Hi,

For some reason I spend some hours, two days in a row, trying to debug
why a newer
kernel didn't work on our machines. It worked just fine with the older kernel...

And there was no network interfaces to see or try to figure out what
was going on with.

Playing with the infiniband tools all i could see was things like:
...
state: 1: DOWN
phys state: 3: Disabled
cat: /sys/class/infiniband/mlx5_0/ports/1/rate: Invalid argument
rate: unknown
link_layer: Ethernet
...

It turns out that the kernel was compiled with mlx5_en disabled, since
it's the default

Unless there is a really good reason not to, lets change the default
value to 'y' =)

I'm hoping that this will lead to others not experiencing the same
surreal journey of
trying to debug this ;)

----

The mellanox driver supports both ethernet and infiniband, but it
is located in the ethernet drivers - the ethernet support should
default to 'yes'.

Signed-off-by: Ian Kumlien <ian.kumlien@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index ddb4ca4ff930..206894f06dec 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -15,7 +15,7 @@ config MLX5_CORE_EN
  bool "Mellanox Technologies ConnectX-4 Ethernet support"
  depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
  imply PTP_1588_CLOCK
- default n
+ default y
  ---help---
   Ethernet support in Mellanox Technologies ConnectX-4 NIC.

-- 
2.12.2

--001a113c05a881ab22054db27f5a
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-Switch-mlx5_en-default-configiuration-value.patch"
Content-Disposition: attachment;
	filename="0001-Switch-mlx5_en-default-configiuration-value.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j1s8nw4a0

RnJvbSAxOWJjOGExOGZlNzkzMTc3ZTc1MzU4OWZmZDY5OTkyNDM0ZjM4MzQ4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBJYW4gS3VtbGllbiA8aWFuLmt1bWxpZW5AZ21haWwuY29tPgpE
YXRlOiBGcmksIDIxIEFwciAyMDE3IDIxOjMwOjMwICswMjAwClN1YmplY3Q6IFtQQVRDSF0gU3dp
dGNoIG1seDVfZW4gZGVmYXVsdCBjb25maWdpdXJhdGlvbiB2YWx1ZQoKVGhlIG1lbGxhbm94IGRy
aXZlciBzdXBwb3J0cyBib3RoIGV0aGVybmV0IGFuZCBpbmZpbmliYW5kLCBidXQgaXQKaXMgbG9j
YXRlZCBpbiB0aGUgZXRoZXJuZXQgZHJpdmVycyAtIHRoZSBldGhlcm5ldCBzdXBwb3J0IHNob3Vs
ZApkZWZhdWx0IHRvICd5ZXMnLgoKU2lnbmVkLW9mZi1ieTogSWFuIEt1bWxpZW4gPGlhbi5rdW1s
aWVuQGdtYWlsLmNvbT4KLS0tCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHg1L2Nv
cmUvS2NvbmZpZyB8IDIgKy0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxl
dGlvbigtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUv
Y29yZS9LY29uZmlnIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVsbGFub3gvbWx4NS9jb3JlL0tj
b25maWcKaW5kZXggZGRiNGNhNGZmOTMwLi4yMDY4OTRmMDZkZWMgMTAwNjQ0Ci0tLSBhL2RyaXZl
cnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUvY29yZS9LY29uZmlnCisrKyBiL2RyaXZlcnMv
bmV0L2V0aGVybmV0L21lbGxhbm94L21seDUvY29yZS9LY29uZmlnCkBAIC0xNSw3ICsxNSw3IEBA
IGNvbmZpZyBNTFg1X0NPUkVfRU4KIAlib29sICJNZWxsYW5veCBUZWNobm9sb2dpZXMgQ29ubmVj
dFgtNCBFdGhlcm5ldCBzdXBwb3J0IgogCWRlcGVuZHMgb24gTkVUREVWSUNFUyAmJiBFVEhFUk5F
VCAmJiBQQ0kgJiYgTUxYNV9DT1JFCiAJaW1wbHkgUFRQXzE1ODhfQ0xPQ0sKLQlkZWZhdWx0IG4K
KwlkZWZhdWx0IHkKIAktLS1oZWxwLS0tCiAJICBFdGhlcm5ldCBzdXBwb3J0IGluIE1lbGxhbm94
IFRlY2hub2xvZ2llcyBDb25uZWN0WC00IE5JQy4KIAotLSAKMi4xMi4yCgo=
--001a113c05a881ab22054db27f5a--
