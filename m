From: "Dirk Opfer" <Dirk@Opfer-Online.de>
Subject: [PATCH] Fix dm9000 release_resource
Date: Wed, 30 Aug 2006 09:04:45 +0200 (CEST)
Message-ID: <0ML25U-1GIK892FsT-0007pS@mrelayeu.kundenserver.de>
Reply-To: Dirk@Opfer-Online.de
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20060830090445_20254"
Cc: "Ben Dooks" <ben@simtec.co.uk>,
	"Sascha Hauer" <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:61912 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750767AbWH3HFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 03:05:01 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_20060830090445_20254
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

dm9000_release_board calls release_resource with the platform resource
instead of the requested resource:

db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
db->addr_req = request_mem_region(db->addr_res->start, i, pdev->name);

dm9000_release_board:

    if (db->addr_res != NULL) {
        release_resource(db->addr_res);
        kfree(db->addr_req);

With this behavior the kernel will crash on the second removal. The
attached patch fix this problem.


Signed-off-by: Dirk Opfer <Dirk@Opfer-Online.de>

------=_20060830090445_20254
Content-Type: application/octet-stream;
      name="dm9000-fix-release-ressource.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
      filename="dm9000-fix-release-ressource.patch"

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2RtOTAwMC5jIGIvZHJpdmVycy9uZXQvZG05MDAwLmMK
aW5kZXggM2Q3NmZhMS4uYTg2MGViYiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZG05MDAwLmMK
KysrIGIvZHJpdmVycy9uZXQvZG05MDAwLmMKQEAgLTM3Nyw4ICszNzcsOCBAQCBkbTkwMDBfcmVs
ZWFzZV9ib2FyZChzdHJ1Y3QgcGxhdGZvcm1fZGV2CiAJCWtmcmVlKGRiLT5kYXRhX3JlcSk7CiAJ
fQogCi0JaWYgKGRiLT5hZGRyX3JlcyAhPSBOVUxMKSB7Ci0JCXJlbGVhc2VfcmVzb3VyY2UoZGIt
PmFkZHJfcmVzKTsKKwlpZiAoZGItPmFkZHJfcmVxICE9IE5VTEwpIHsKKwkJcmVsZWFzZV9yZXNv
dXJjZShkYi0+YWRkcl9yZXEpOwogCQlrZnJlZShkYi0+YWRkcl9yZXEpOwogCX0KIH0K
------=_20060830090445_20254--


