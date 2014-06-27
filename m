From: roy.qing.li@gmail.com
Subject: [PATCH] enic: fix a building failure
Date: Fri, 27 Jun 2014 10:09:39 +0800
Message-ID: <1403834979-598-1-git-send-email-roy.qing.li@gmail.com>
References: <CA+r1ZhjoME0Okxi9kfFgOsMmieWwuhCX83DCKosKEM2NLAtAVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jim.epost@gmail.com, _govind@gmx.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60678 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbaF0CJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 22:09:40 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so3949112pac.33
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 19:09:40 -0700 (PDT)
In-Reply-To: <CA+r1ZhjoME0Okxi9kfFgOsMmieWwuhCX83DCKosKEM2NLAtAVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Li RongQing <roy.qing.li@gmail.com>

When RFS_ACCEL is disabled, the building failed:
    drivers/net/ethernet/cisco/enic/enic_main.c: In function =E2=80=98e=
nic_open=E2=80=99:
    drivers/net/ethernet/cisco/enic/enic_main.c:1603:2: error: implicit=
 declaration
    of function =E2=80=98enic_rfs_flw_tbl_init=E2=80=99 [-Werror=3Dimpl=
icit-function-declaration]
      enic_rfs_flw_tbl_init(enic);
      ^
    drivers/net/ethernet/cisco/enic/enic_main.c: In function =E2=80=98e=
nic_stop=E2=80=99:
    drivers/net/ethernet/cisco/enic/enic_main.c:1630:2: error: implicit=
 declaration
    of function =E2=80=98enic_rfs_flw_tbl_free=E2=80=99 [-Werror=3Dimpl=
icit-function-declaration]
      enic_rfs_flw_tbl_free(enic);

In fact, these two functions have been defined separately for enabling =
RFS_ACCEL
and disabling RFS_ACCEL.

Reported-by: Jim Davis <jim.epost@gmail.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/cisco/enic/enic_clsf.h |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.h b/drivers/net/=
ethernet/cisco/enic/enic_clsf.h
index 76a85bb..b38cc7e 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.h
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.h
@@ -9,11 +9,8 @@
 int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)=
;
 int enic_delfltr(struct enic *enic, u16 filter_id);
=20
-#ifdef CONFIG_RFS_ACCEL
 void enic_rfs_flw_tbl_init(struct enic *enic);
 void enic_rfs_flw_tbl_free(struct enic *enic);
 int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *s=
kb,
 		       u16 rxq_index, u32 flow_id);
-#endif /* CONFIG_RFS_ACCEL */
-
 #endif /* _ENIC_CLSF_H_ */
--=20
1.7.10.4
