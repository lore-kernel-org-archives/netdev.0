From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net] bnx2x: fix vector traveling while looking for an
 empty entry
Date: Tue, 27 Mar 2012 11:06:39 -0700
Message-ID: <CAHo-OowjXKjiqvCiYitBU=sEefi7QN45D5MBs1=gzwQN9dF7sg@mail.gmail.com>
References: <1332832135-22054-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47763 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755097Ab2C0SGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 14:06:40 -0400
Received: by yenl12 with SMTP id l12so172926yen.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 11:06:40 -0700 (PDT)
In-Reply-To: <1332832135-22054-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack.

On Tue, Mar 27, 2012 at 00:08, Dmitry Kravkov <dmitry@broadcom.com> wro=
te:
> Fixes the bug that may prevent from mac to be configured,
> while there is an empty slot for it.
>
> Reported-by: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> ---
> =C2=A0drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | =C2=A0 =C2=A02=
 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> index 3f52fad..5135733 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> @@ -3847,7 +3847,7 @@ static bool bnx2x_credit_pool_get_entry(
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If we've go=
t here we are going to find a free entry */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (idx =3D vec *=
 BNX2X_POOL_VEC_SIZE, i =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (idx =3D vec *=
 BIT_VEC64_ELEM_SZ, i =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0i < BIT_VEC64_ELEM_SZ; idx++, i++)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (BIT_VEC64_TEST_BIT(o->pool_mirror, idx)) {
> --
> 1.7.7.2
>
>
