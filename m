From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net 4/4] net: hns: remove useless
 head=ring->next_to_clean
Date: Tue, 08 Mar 2016 09:18:08 +0200
Message-ID: <1457421488.1347.5.camel@linux.intel.com>
References: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
	 <1457409147-77086-5-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yisen.zhuang@huawei.com, yankejian@huawei.com,
	xieqianqian@huawei.com, huangdaode@hisilicon.com,
	salil.mehta@huawei.com, netdev@vger.kernel.org,
	haifeng.wei@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Lisheng <lisheng011@huawei.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55741 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753489AbcCHHRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 02:17:22 -0500
In-Reply-To: <1457409147-77086-5-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-08 at 11:52 +0800, Lisheng wrote:
> From: Qianqian Xie <xieqianqian@huawei.com>
>=20
> The variable head in hns_nic_tx_fini_pro has read a value,
> but the value is not used. The patch will solve it.
>=20
> Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
> ---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_enet.c | 4 +---
> =C2=A01 file changed, 1 insertion(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> index 3f77ff7..7b4ec2f 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -901,10 +901,8 @@ static int hns_nic_tx_poll_one(struct
> hns_nic_ring_data *ring_data,
> =C2=A0static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_=
data)
> =C2=A0{
> =C2=A0	struct hnae_ring *ring =3D ring_data->ring;
> -	int head =3D ring->next_to_clean;
> =C2=A0

This empty line is a leftover, I prefer to just cut assignment.

> -	/* for hardware bug fixed */

This is not good. Explanation is needed why you removed this comment.

> -	head =3D readl_relaxed(ring->io_base + RCB_REG_HEAD);
> +	int head =3D readl_relaxed(ring->io_base + RCB_REG_HEAD);
> =C2=A0
> =C2=A0	if (head !=3D ring->next_to_clean) {
> =C2=A0		ring_data->ring->q->handle->dev->ops-
> >toggle_ring_irq(

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
