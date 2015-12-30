From: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mwifiex: correctly handling kzalloc
Date: Wed, 30 Dec 2015 03:37:06 +0200
Message-ID: <CAHp75VdZHrXbUytAcXzitH8zzELjimNihG5LfLqX85u4y502SA@mail.gmail.com>
References: <1451420268-15862-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"open list:TI WILINK WIRELES..." <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	taesoo-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, yeongjin.jang-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, insu-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org,
	changwoo-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org
To: Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451420268-15862-1-git-send-email-wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2015 at 10:17 PM, Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

Empty commit message?

> Signed-off-by: Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/mwifiex/sdio.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
> index 78a8474..a8af72d 100644
> --- a/drivers/net/wireless/mwifiex/sdio.c
> +++ b/drivers/net/wireless/mwifiex/sdio.c
> @@ -2053,8 +2053,19 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *adapter)
>         /* Allocate skb pointer buffers */
>         card->mpa_rx.skb_arr = kzalloc((sizeof(void *)) *
>                                        card->mp_agg_pkt_limit, GFP_KERNEL);

Just noticed: Looks like good candidate for kcalloc or kmalloc_array,
whichever is suitable.

> +       if (!card->mpa_rx.skb_arr) {
> +               kfree(card->mp_regs);
> +               return -ENOMEM;
> +       }
> +
>         card->mpa_rx.len_arr = kzalloc(sizeof(*card->mpa_rx.len_arr) *
>                                        card->mp_agg_pkt_limit, GFP_KERNEL);

Ditto.

> +       if (!card->mpa_rx.len_arr) {
> +               kfree(card->mp_regs);
> +               kfree(card->mpa_rx.skb_arr);


> +               return -ENOMEM;
> +       }
> +
>         ret = mwifiex_alloc_sdio_mpa_buffers(adapter,
>                                              card->mp_tx_agg_buf_size,
>                                              card->mp_rx_agg_buf_size);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
