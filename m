From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH net-next 1/2] mlx4_core: fix mtt range deallocation
Date: Mon, 2 Jan 2012 14:05:02 -0800
Message-ID: <CAE9FiQX+LkhifWTAQLfGfPyogOKUmuWNS2cuyL5wm36hoAJS6A@mail.gmail.com>
References: <4F01BA2B.1060605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	marcela@dev.mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56654 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab2ABWFD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 17:05:03 -0500
Received: by yhr47 with SMTP id 47so9227027yhr.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 14:05:02 -0800 (PST)
In-Reply-To: <4F01BA2B.1060605@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2012 at 6:07 AM, Yevgeny Petrilin
<yevgenyp@mellanox.co.il> wrote:
> From: Marcel Apfelbaum <marcela@mellanox.co.il>
>
> The mtt range was allocated in mtt units but deallocated
> in segments. Among the rest, this caused crash during hotplug removal
>
> Reported-by: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Marcel Apfelbaum <marcela@mellanox.co.il>
> Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> ---
> =A0drivers/net/ethernet/mellanox/mlx4/mr.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/et=
hernet/mellanox/mlx4/mr.c
> index f7243b2..01df556 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mr.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
> @@ -239,8 +239,8 @@ void __mlx4_free_mtt_range(struct mlx4_dev *dev, =
u32 offset, int order)
> =A0 =A0 =A0 =A0first_seg =3D offset / (1 << log_mtts_per_seg);
>
> =A0 =A0 =A0 =A0mlx4_buddy_free(&mr_table->mtt_buddy, first_seg, seg_o=
rder);
> - =A0 =A0 =A0 mlx4_table_put_range(dev, &mr_table->mtt_table, first_s=
eg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0first_seg + =
(1 << seg_order) - 1);
> + =A0 =A0 =A0 mlx4_table_put_range(dev, &mr_table->mtt_table, offset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0offset + (1 =
<< order) - 1);
> =A0}
>
> =A0static void mlx4_free_mtt_range(struct mlx4_dev *dev, u32 offset, =
int order)

Tested-by: Yinghai Lu <yinghai@kernel.org>
