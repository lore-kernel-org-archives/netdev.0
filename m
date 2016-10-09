From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed: Fix to use list_for_each_entry_safe() when delete
 items
Date: Sun, 9 Oct 2016 13:44:42 +0000
Message-ID: <BL2PR07MB2306DE6412B6516663F3BE608DD80@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0061.outbound.protection.outlook.com ([104.47.34.61]:23936
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751798AbcJIOUI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Oct 2016 10:20:08 -0400
In-Reply-To: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Wei Yongjun <weiyongjun1@huawei.com>
>=20
> Since we will remove items off the list using list_del() we need to use a=
 safe
> version of the list_for_each_entry() macro aptly named
> list_for_each_entry_safe().
>=20
> Fixes: 0a7fb11c23c0 ("qed: Add Light L2 support")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_ll2.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> index a6db107..4428333 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> @@ -1517,7 +1517,7 @@ static void qed_ll2_register_cb_ops(struct qed_dev
> *cdev,  static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_par=
ams
> *params)  {
>  	struct qed_ll2_info ll2_info;
> -	struct qed_ll2_buffer *buffer;
> +	struct qed_ll2_buffer *buffer, *tmp;
>  	enum qed_ll2_conn_type conn_type;
>  	struct qed_ptt *p_ptt;
>  	int rc, i;
> @@ -1587,7 +1587,7 @@ static int qed_ll2_start(struct qed_dev *cdev, stru=
ct
> qed_ll2_params *params)
>=20
>  	/* Post all Rx buffers to FW */
>  	spin_lock_bh(&cdev->ll2->lock);
> -	list_for_each_entry(buffer, &cdev->ll2->list, list) {
> +	list_for_each_entry_safe(buffer, tmp, &cdev->ll2->list, list) {
>  		rc =3D qed_ll2_post_rx_buffer(QED_LEADING_HWFN(cdev),
>  					    cdev->ll2->handle,
>  					    buffer->phys_addr, 0, buffer, 1);

Thanks for the catch.

A single petty comment - having the variable called 'tmp' in such a long
function is far from informative. Perhaps 'tmp_buffer' would have been
better.

Regardless,
Acked-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
