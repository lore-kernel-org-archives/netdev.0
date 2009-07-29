From: "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH] iscsi: Use GFP_ATOMIC in iscsi_offload_mesg().
Date: Wed, 29 Jul 2009 11:49:52 -0700
Message-ID: <1248893392.16148.262.camel@HP1>
References: <C27F8246C663564A84BB7AB343977242178EE780E1@IRVEXCHCCR01.corp.ad.broadcom.com> <4A70058F.50403@cs.wisc.edu>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org" <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: "Mike Christie" <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <4A70058F.50403-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


Changing to GFP_ATOMIC because the only caller in cnic/bnx2i may
be calling this function while holding spin_lock.

This problem was discovered by Mike Christie.

Signed-off-by: Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/scsi/scsi_transport_iscsi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 783e33c..b47240c 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -990,7 +990,7 @@ int iscsi_offload_mesg(struct Scsi_Host *shost,
 	struct iscsi_uevent *ev;
 	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
 
-	skb = alloc_skb(len, GFP_NOIO);
+	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb) {
 		printk(KERN_ERR "can not deliver iscsi offload message:OOM\n");
 		return -ENOMEM;
@@ -1012,7 +1012,7 @@ int iscsi_offload_mesg(struct Scsi_Host *shost,
 
 	memcpy((char *)ev + sizeof(*ev), data, data_size);
 
-	return iscsi_multicast_skb(skb, ISCSI_NL_GRP_UIP, GFP_NOIO);
+	return iscsi_multicast_skb(skb, ISCSI_NL_GRP_UIP, GFP_ATOMIC);
 }
 EXPORT_SYMBOL_GPL(iscsi_offload_mesg);
 
-- 
1.5.6.GIT
