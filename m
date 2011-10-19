From: roy.qing.li@gmail.com
Subject: [PATCH net-next] igb: fix a compile warning
Date: Wed, 19 Oct 2011 16:52:35 +0800
Message-ID: <1319014355-15678-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45533 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab1JSIwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 04:52:45 -0400
Received: by wyg36 with SMTP id 36so1470884wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 01:52:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: RongQing Li <roy.qing.li@gmail.com>

control these three function declarations and
definitions with same macro CONFIG_PCI_IOV

drivers/net/ethernet/intel/igb/igb_main.c:165:
warning: =E2=80=98igb_vf_configure=E2=80=99 declared =E2=80=98static=E2=
=80=99 but never defined
drivers/net/ethernet/intel/igb/igb_main.c:166:
warning: =E2=80=98igb_find_enabled_vfs=E2=80=99 declared =E2=80=98stati=
c=E2=80=99 but never defined
drivers/net/ethernet/intel/igb/igb_main.c:167:
warning: =E2=80=98igb_check_vf_assignment=E2=80=99 declared =E2=80=98st=
atic=E2=80=99 but never defined

Signed-off-by: RongQing Li <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/et=
hernet/intel/igb/igb_main.c
index 837adbb..5d16cdc 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -162,9 +162,12 @@ static int igb_ndo_set_vf_bw(struct net_device *ne=
tdev, int vf, int tx_rate);
 static int igb_ndo_get_vf_config(struct net_device *netdev, int vf,
 				 struct ifla_vf_info *ivi);
 static void igb_check_vf_rate_limit(struct igb_adapter *);
+
+#ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
 static int igb_find_enabled_vfs(struct igb_adapter *adapter);
 static int igb_check_vf_assignment(struct igb_adapter *adapter);
+#endif
=20
 #ifdef CONFIG_PM
 static int igb_suspend(struct pci_dev *, pm_message_t);
--=20
1.7.1
