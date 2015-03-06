From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] igb: Fix warning pin may be used uninitialized
Date: Fri,  6 Mar 2015 03:06:03 -0800
Message-ID: <1425639966-6829-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14541 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756080AbbCFLGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 06:06:12 -0500
In-Reply-To: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alexander Duyck <alexander.h.duyck@redhat.com>

When building the kernel using the gcc 4.8.3 compiler included in Fedor=
a 20
I was repeatedly seeing the warning:

 drivers/net/ethernet/intel/igb/igb_ptp.c: In function =E2=80=98igb_ptp=
_feature_enable_i210=E2=80=99:
 drivers/net/ethernet/intel/igb/igb_ptp.c:395:21: warning: =E2=80=98pin=
=E2=80=99 may be used uninitialized in this function
 [-Wmaybe-uninitialized]
   tssdp &=3D ~ts_sdp_en[pin];
                     ^
 drivers/net/ethernet/intel/igb/igb_ptp.c:471:6: note: =E2=80=98pin=E2=80=
=99 was declared here
   int pin;
       ^

To resolve it I am assigning the pin a value of -1 when it is instantia=
ted.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/eth=
ernet/intel/igb/igb_ptp.c
index d20fc8e..525e5c4 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -468,7 +468,7 @@ static int igb_ptp_feature_enable_i210(struct ptp_c=
lock_info *ptp,
 	u32 tsauxc, tsim, tsauxc_mask, tsim_mask, trgttiml, trgttimh;
 	unsigned long flags;
 	struct timespec ts;
-	int pin;
+	int pin =3D -1;
 	s64 ns;
=20
 	switch (rq->type) {
--=20
1.9.3
