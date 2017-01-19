From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH 2/3] qed: avoid possible stack overflow in
 qed_ll2_acquire_connection
Date: Thu, 19 Jan 2017 13:13:30 +0000
Message-ID: <BL2PR07MB2306B71885EAA9BB808414358D7E0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170118145306.1004008-1-arnd@arndb.de>
 <20170118145306.1004008-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        "Hannes Reinecke" <hare@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Dept-Eng Everest Linux L2" <Dept-EngEverestLinuxL2@cavium.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0071.outbound.protection.outlook.com ([104.47.38.71]:4512
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751931AbdASNOG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 08:14:06 -0500
In-Reply-To: <20170118145306.1004008-2-arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 968,23 +968,19 @@ static int qed_ll2_start_ooo(struct qed_dev *cdev,  {
>  	struct qed_hwfn *hwfn =3D QED_LEADING_HWFN(cdev);
>  	u8 *handle =3D &hwfn->pf_params.iscsi_pf_params.ll2_ooo_queue_id;
> -	struct qed_ll2_info *ll2_info;
> +	struct qed_ll2_conn ll2_info;

A bit confusing to change the type from qed_ll2_info - > qed_ll2_conn
yet leave the variable named 'll2_info'.
Probably better to have it name `ll2_params' as in:

> @@ -2632,7 +2632,7 @@ static int qed_roce_ll2_start(struct qed_dev *cdev,
> {
>  	struct qed_hwfn *hwfn =3D QED_LEADING_HWFN(cdev);
>  	struct qed_roce_ll2_info *roce_ll2;
> -	struct qed_ll2_info ll2_params;
> +	struct qed_ll2_conn ll2_params;

But that's nitpicking; You can do this if for some reason you'll need a v2,
or we'll later change it in some semantic patch.

Thanks for taking care of this.

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
