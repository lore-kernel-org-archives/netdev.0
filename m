From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: =?windows-1252?Q?=5BPATCH=5Dnetxen=3Afix_compile_waring_=22?=
 =?windows-1252?Q?label_=91set=5F32=5Fbit=5Fmask=92_defined_but_n?=
 =?windows-1252?Q?ot_used=22_on_IA64_platform?=
Date: Thu, 12 Feb 2009 16:03:51 +0800
Message-ID: <4993D7E7.5060300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50146 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbZBLICl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 03:02:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When compile the latest kernel on IA64 platform,I got a warning:
drivers/net/netxen/netxen_nic_main.c:203: warning: label =91set_32_bit_=
mask=92=20
defined but not used

We do not need label =91set_32_bit_mask=92  on IA64 platform,So move it=
 to #else.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index 3b17a79..b0ac5d6 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -201,9 +201,9 @@ static int nx_set_dma_mask(struct netxen_adapter *a=
dapter, uint8_t revision_id)
 		adapter->pci_using_dac =3D 1;
 		return 0;
 	}
+set_32_bit_mask:
 #endif /* CONFIG_IA64 */
=20
-set_32_bit_mask:
 	err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (!err)
 		err =3D pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
--=20
1.6.0.3


--=20
Regards
Yang Hongyang
