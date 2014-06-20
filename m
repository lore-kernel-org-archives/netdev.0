From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [net-next 01/13] i40e/i40evf: i40e_register.h update
Date: Fri, 20 Jun 2014 11:07:34 +0200
Message-ID: <87a998q78p.fsf@nemi.mork.no>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1403250588-14356-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34382 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964815AbaFTJH7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 05:07:59 -0400
In-Reply-To: <1403250588-14356-2-git-send-email-jeffrey.t.kirsher@intel.com>
	(Jeff Kirsher's message of "Fri, 20 Jun 2014 00:49:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:

>  drivers/net/ethernet/intel/i40e/i40e_main.c       |   30 +-
>  drivers/net/ethernet/intel/i40e/i40e_register.h   | 5011 ++++++++---=
----------
>  drivers/net/ethernet/intel/i40e/i40e_type.h       |    3 +
>  drivers/net/ethernet/intel/i40evf/i40e_register.h | 5011 ++++++++---=
----------
>  drivers/net/ethernet/intel/i40evf/i40e_type.h     |    3 +
>  5 files changed, 3728 insertions(+), 6330 deletions(-)

Not really a comment on this patch, but the diffstat above made me
suspect that you have lots of duplicates here...  Does it *really* make
sense to maintain syncronized copies of these rather large header files=
,
just because a total of 3 lines are different (not counting the
unneccessary header diff and the assumed unwanted whitespace diff)?


bjorn@nemi:/usr/local/src/git/linux$ ls -l drivers/net/ethernet/intel/i=
40e*/i40e_register.h
-rw-r--r-- 1 bjorn adm 296849 Jun 19 14:33 drivers/net/ethernet/intel/i=
40e/i40e_register.h
-rw-r--r-- 1 bjorn adm 296965 Jun 19 14:33 drivers/net/ethernet/intel/i=
40evf/i40e_register.h
bjorn@nemi:/usr/local/src/git/linux$ ls -l drivers/net/ethernet/intel/i=
40e*/i40e_type.h
-rw-r--r-- 1 bjorn adm 33485 Jun 19 14:33 drivers/net/ethernet/intel/i4=
0e/i40e_type.h
-rw-r--r-- 1 bjorn adm 33501 Jun 19 14:33 drivers/net/ethernet/intel/i4=
0evf/i40e_type.h

bjorn@nemi:/usr/local/src/git/linux$ diff -u drivers/net/ethernet/intel=
/i40e*/i40e_type.h
--- drivers/net/ethernet/intel/i40e/i40e_type.h 2014-06-19 14:33:09.483=
646548 +0200
+++ drivers/net/ethernet/intel/i40evf/i40e_type.h       2014-06-19 14:3=
3:09.499646658 +0200
@@ -1,6 +1,6 @@
 /*********************************************************************=
**********
  *
- * Intel Ethernet Controller XL710 Family Linux Driver
+ * Intel Ethernet Controller XL710 Family Linux Virtual Function Drive=
r
  * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modif=
y it
@@ -43,7 +43,7 @@
 #define I40E_DEV_ID_QSFP_A             0x1583
 #define I40E_DEV_ID_QSFP_B             0x1584
 #define I40E_DEV_ID_QSFP_C             0x1585
-#define I40E_DEV_ID_VF                 0x154C
+#define I40E_DEV_ID_VF         0x154C
 #define I40E_DEV_ID_VF_HV              0x1571
=20
 #define i40e_is_40G_device(d)          ((d) =3D=3D I40E_DEV_ID_QSFP_A =
 || \

bjorn@nemi:/usr/local/src/git/linux$ diff -u drivers/net/ethernet/intel=
/i40e*/i40e_register.h
--- drivers/net/ethernet/intel/i40e/i40e_register.h     2014-06-19 14:3=
3:09.475646493 +0200
+++ drivers/net/ethernet/intel/i40evf/i40e_register.h   2014-06-19 14:3=
3:09.495646636 +0200
@@ -1,6 +1,6 @@
 /*********************************************************************=
**********
  *
- * Intel Ethernet Controller XL710 Family Linux Driver
+ * Intel Ethernet Controller XL710 Family Linux Virtual Function Drive=
r
  * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modif=
y it
@@ -189,7 +189,7 @@
 #define I40E_PFCM_LAN_ERRINFO_RLU_ERROR_CNT_MASK (0xFF << I40E_PFCM_LA=
N_ERRINFO_RLU_ERROR_CNT_SHIFT)
 #define I40E_PFCM_LAN_ERRINFO_RLS_ERROR_CNT_SHIFT 24
 #define I40E_PFCM_LAN_ERRINFO_RLS_ERROR_CNT_MASK (0xFF << I40E_PFCM_LA=
N_ERRINFO_RLS_ERROR_CNT_SHIFT)
-#define I40E_PFCM_LANCTXCTL 0x0010C300
+#define I40E_PFCM_LANCTXCTL(_pf) (0x0010C300 + ((_pf) * 4))/* _pf=3D0.=
=2E15 */
 #define I40E_PFCM_LANCTXCTL_QUEUE_NUM_SHIFT 0
 #define I40E_PFCM_LANCTXCTL_QUEUE_NUM_MASK (0xFFF << I40E_PFCM_LANCTXC=
TL_QUEUE_NUM_SHIFT)
 #define I40E_PFCM_LANCTXCTL_SUB_LINE_SHIFT 12
@@ -198,11 +198,11 @@
 #define I40E_PFCM_LANCTXCTL_QUEUE_TYPE_MASK (0x3 << I40E_PFCM_LANCTXCT=
L_QUEUE_TYPE_SHIFT)
 #define I40E_PFCM_LANCTXCTL_OP_CODE_SHIFT 17
 #define I40E_PFCM_LANCTXCTL_OP_CODE_MASK (0x3 << I40E_PFCM_LANCTXCTL_O=
P_CODE_SHIFT)
-#define I40E_PFCM_LANCTXDATA(_i) (0x0010C100 + ((_i) * 128)) /* _i=3D0=
=2E..3 */
+#define I40E_PFCM_LANCTXDATA(_i, _pf) (0x0010C100 + ((_i) * 4) + ((_pf=
) * 16))/* _i=3D0...3 _pf=3D0..15 */
 #define I40E_PFCM_LANCTXDATA_MAX_INDEX 3
 #define I40E_PFCM_LANCTXDATA_DATA_SHIFT 0
 #define I40E_PFCM_LANCTXDATA_DATA_MASK (0xFFFFFFFF << I40E_PFCM_LANCTX=
DATA_DATA_SHIFT)
-#define I40E_PFCM_LANCTXSTAT 0x0010C380
+#define I40E_PFCM_LANCTXSTAT(_pf) (0x0010C380 + ((_pf) * 4))/* _pf=3D0=
=2E.15 */
 #define I40E_PFCM_LANCTXSTAT_CTX_DONE_SHIFT 0
 #define I40E_PFCM_LANCTXSTAT_CTX_DONE_MASK (0x1 << I40E_PFCM_LANCTXSTA=
T_CTX_DONE_SHIFT)
 #define I40E_PFCM_LANCTXSTAT_CTX_MISS_SHIFT 1




Bj=C3=B8rn
