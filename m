From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/5] ath10k: Remove unused wmi_p2p_noa_descriptor 'noa' in wmi-tlv
Date: Thu, 24 Nov 2016 10:50:19 +0100
Message-ID: <CA+BoTQntqod=Aj7MzuU0KfmbTQb7A-zEcySWqVkycSYE-MqtDQ@mail.gmail.com>
References: <cover.1479974100.git.kirtika@chromium.org> <99d0ff42e57d5f62560e72d926b4d69d5d7c418b.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <99d0ff42e57d5f62560e72d926b4d69d5d7c418b.1479974100.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 24 November 2016 at 09:01, Kirtika Ruchandani
<kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Commit ca996ec56608 (ath10k: implement wmi-tlv backend)
> introduced ath10k_wmi_tlv_op_gen_vdev_start() where
> 'struct wmi_p2p_noa_descriptor *noa' is defined and set but not used.
> Compiling with W=3D1 gives the following warning, fix it.
> drivers/net/wireless/ath/ath10k/wmi-tlv.c: In function =E2=80=98ath10k_wm=
i_tlv_op_gen_vdev_start=E2=80=99:
> drivers/net/wireless/ath/ath10k/wmi-tlv.c:1647:33: warning: variable =E2=
=80=98noa=E2=80=99 set but not used [-Wunused-but-set-variable]
>
> Fixes: ca996ec56608 ("ath10k: implement wmi-tlv backend")
> Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
> Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  drivers/net/wireless/ath/ath10k/wmi-tlv.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath10k/wmi-tlv.c b/drivers/net/wire=
less/ath/ath10k/wmi-tlv.c
> index e64f593..0e4bd29 100644
> --- a/drivers/net/wireless/ath/ath10k/wmi-tlv.c
> +++ b/drivers/net/wireless/ath/ath10k/wmi-tlv.c
> @@ -1644,7 +1644,6 @@ ath10k_wmi_tlv_op_gen_vdev_start(struct ath10k *ar,
>  {
>         struct wmi_tlv_vdev_start_cmd *cmd;
>         struct wmi_channel *ch;
> -       struct wmi_p2p_noa_descriptor *noa;
>         struct wmi_tlv *tlv;
>         struct sk_buff *skb;
>         size_t len;
> @@ -1702,7 +1701,6 @@ ath10k_wmi_tlv_op_gen_vdev_start(struct ath10k *ar,
>         tlv =3D ptr;
>         tlv->tag =3D __cpu_to_le16(WMI_TLV_TAG_ARRAY_STRUCT);
>         tlv->len =3D 0;
> -       noa =3D (void *)tlv->value;
>
>         /* Note: This is a nested TLV containing:
>          * [wmi_tlv][wmi_p2p_noa_descriptor][wmi_tlv]..

I would rather keep this one as it serves as documentation. Would
"(void) noa;" be enough satisfy the compiler?


Micha=C5=82
