From: "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Subject: RE: [PATCH] qed: remove unnecessary call to memset
Date: Wed, 13 Sep 2017 09:15:53 +0000
Message-ID: <CY4PR07MB304841CE18FAB9B14BCCEBC88A6E0@CY4PR07MB3048.namprd07.prod.outlook.com>
References: <1505215162-3917-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Himanshu Jha <himanshujha199640@gmail.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505215162-3917-1-git-send-email-himanshujha199640@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: Himanshu Jha [mailto:himanshujha199640@gmail.com]=20
Sent: 12 September 2017 16:49
To: Mintz, Yuval <Yuval.Mintz@cavium.com>
Cc: Elior, Ariel <Ariel.Elior@cavium.com>; Dept-Eng Everest Linux L2 <Dept-=
EngEverestLinuxL2@cavium.com>; netdev@vger.kernel.org; linux-kernel@vger.ke=
rnel.org; Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] qed: remove unnecessary call to memset

call to memset to assign 0 value immediately after allocating memory with k=
zalloc is unnecesaary as kzalloc allocates the memory filled with 0 value.

Semantic patch used to resolve this issue:

@@
expression e,e2; constant c;
statement S;
@@

  e =3D kzalloc(e2, c);
  if(e =3D=3D NULL) S
- memset(e, 0, e2);

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ether=
net/qlogic/qed/qed_dcbx.c
index eaca457..8f6ccc0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1244,7 +1244,6 @@ int qed_dcbx_get_config_params(struct qed_hwfn *p_hwf=
n,
 	if (!dcbx_info)
 		return -ENOMEM;
=20
-	memset(dcbx_info, 0, sizeof(*dcbx_info));
 	rc =3D qed_dcbx_query_params(p_hwfn, dcbx_info, QED_DCBX_OPERATIONAL_MIB)=
;
 	if (rc) {
 		kfree(dcbx_info);
--
2.7.4

Acked-by: Sudarsana Kalluru <sudarsana.kalluru@cavium.com>
