From: Joe Perches <joe@perches.com>
Subject: [PATCH] bnx2x: Convert return 0 to return rc
Date: Thu, 15 May 2014 23:51:43 -0700
Message-ID: <1400223103.30884.5.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ariel Elior <ariele@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These "return 0;" uses seem wrong as there are
rc variables where error return values are set
but unused.

Signed-off-by: Joe Perches <joe@perches.com>
---

Hey Ariel/Dmitry

I've no idea what's right here, but the current
code seems wrong. (or at least under-commented)

It seems Dmitry changed these, perhaps to make
it more readable, but the commit log isn't very
instructive.

commit 1d6f3cd8988822c7bdc3c685fac0a99315e83400
Author: Dmitry Kravkov <dmitry@broadcom.com>
Date:   Wed Mar 27 01:05:17 2013 +0000

    bnx2x: Prevent VF race
    
    The mail box containing the Vf-Pf messages is susceptible
    to a race - it's possible for 2 flows to try and write commands,
    causing one to override the other's message.
    Use a mutex to synchronize the access, preventing said race.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 81cc2d9..b8078d5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2695,7 +2695,7 @@ out:
 		bnx2x_unlock_vf_pf_channel(bp, vf, CHANNEL_TLV_PF_SET_MAC);
 	}
 
-	return 0;
+	return rc;
 }
 
 int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 0c067e8..784c715 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -747,7 +747,7 @@ int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr, u8 vf_qid, bool set)
 out:
 	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
-	return 0;
+	return rc;
 }
 
 /* request pf to config rss table for vf queues*/
