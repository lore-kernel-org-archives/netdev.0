From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Sat, 14 Sep 2013 22:10:19 +0300
Message-ID: <CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Prarit Bhargava <prarit@redhat.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:63103 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756745Ab3INTKU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 15:10:20 -0400
Received: by mail-qa0-f51.google.com with SMTP id j15so246468qaq.3
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 12:10:19 -0700 (PDT)
In-Reply-To: <1379075438-20240-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 3:30 PM, Prarit Bhargava <prarit@redhat.com> wr=
ote:
> Fix unitialized variable warnings.

Hi,

I'd like Jack, who is in charge on this code to take a look, added him.

Or.

>
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =91=
mlx4_HW2SW_CQ_wrapper=92:
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2551:16: error:=
 =91cq=92 may be used uninitialized in this function [-Werror=3Dmaybe-u=
ninitialized]
>   atomic_dec(&cq->mtt->ref_count);
>                 ^
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =91=
mlx4_HW2SW_SRQ_wrapper=92:
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2734:17: error:=
 =91srq=92 may be used uninitialized in this function [-Werror=3Dmaybe-=
uninitialized]
>   atomic_dec(&srq->mtt->ref_count);
>
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: dledford@redhat.com
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/=
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index dd68763..d703838 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -2563,7 +2563,7 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev,=
 int slave,
>  {
>         int err;
>         int cqn =3D vhcr->in_modifier;
> -       struct res_cq *cq;
> +       struct res_cq *uninitialized_var(cq);
>
>         err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATE=
D, &cq);
>         if (err)
> @@ -2746,7 +2746,7 @@ int mlx4_HW2SW_SRQ_wrapper(struct mlx4_dev *dev=
, int slave,
>  {
>         int err;
>         int srqn =3D vhcr->in_modifier;
> -       struct res_srq *srq;
> +       struct res_srq *uninitialized_var(srq);
>
>         err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOC=
ATED, &srq);
>         if (err)
> --
> 1.7.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
