From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] ixgbevf: fix possible use of uninitialized variable
Date: Tue, 13 Nov 2012 06:03:17 -0800
Message-ID: <1352815405-751-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39128 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab2KMOD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:29 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves the following warning:

drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c: In function =E2=80=98=
ixgbevf_probe=E2=80=99:
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1742:290: warning: =E2=
=80=98err=E2=80=99 may be used uninitialized in this function [-Wuninit=
ialized]
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1717:6: note: =E2=80=98=
err=E2=80=99 was declared here

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/driver=
s/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a8fbe6c..ee5ff0e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1724,7 +1724,8 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapte=
r)
 static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapte=
r,
 					int vectors)
 {
-	int err, vector_threshold;
+	int err =3D 0;
+	int vector_threshold;
=20
 	/* We'll want at least 2 (vector_threshold):
 	 * 1) TxQ[0] + RxQ[0] handler
--=20
1.7.11.7
