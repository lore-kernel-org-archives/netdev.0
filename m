From: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] mwifiex: avoid out of bounds access in
 mwifiex_get_common_rates.
Date: Mon, 28 Jan 2013 10:53:33 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430D142545EE@SC-VEXCH1.marvell.com>
References: <1359326568-17022-1-git-send-email-tipecaml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Cyril Roelandt <tipecaml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359326568-17022-1-git-send-email-tipecaml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Cyril,

Thanks for your patch.

> Check that the array indexes are in-bounds before accessing the rate2 and tmp
> arrays.
> 
> Found with the following semantic patch:
> 
> <smpl>
> @@
> identifier t;
> identifier idx;
> expression E;
> statement S;
> @@
> * for (... ; <+... t[idx] ...+> && idx < E ; ...)
> S
> </smpl>
> 
> Signed-off-by: Cyril Roelandt <tipecaml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>

Thanks,
Bing

> ---
>  drivers/net/wireless/mwifiex/join.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwifiex/join.c
> index 893d809..f0a634d 100644
> --- a/drivers/net/wireless/mwifiex/join.c
> +++ b/drivers/net/wireless/mwifiex/join.c
> @@ -157,8 +157,8 @@ static int mwifiex_get_common_rates(struct mwifiex_private *priv, u8 *rate1,
> 
>  	memset(rate1, 0, rate1_size);
> 
> -	for (i = 0; rate2[i] && i < rate2_size; i++) {
> -		for (j = 0; tmp[j] && j < rate1_size; j++) {
> +	for (i = 0; i < rate2_size && rate2[i]; i++) {
> +		for (j = 0; j < rate1_size && tmp[j]; j++) {
>  			/* Check common rate, excluding the bit for
>  			   basic rate */
>  			if ((rate2[i] & 0x7F) == (tmp[j] & 0x7F)) {
> --
> 1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
