From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/13] libertas: make return of 0 explicit
Date: Mon, 19 May 2014 16:45:04 +0400
Message-ID: <5379FCD0.2030506@cogentembedded.com>
References: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr> <1400473875-22228-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400473875-22228-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 19-05-2014 8:31, Julia Lawall wrote:

> From: Julia Lawall <Julia.Lawall@lip6.fr>

> Delete unnecessary local variable whose value is always 0 and that hides
> the fact that the result is always 0.

> A simplified version of the semantic patch that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)

> // <smpl>
> @r exists@
> local idexpression ret;
> expression e;
> position p;
> @@
>
> -ret = 0;
> ... when != ret = e
> return
> - ret
> + 0
>    ;
> // </smpl>

> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

> ---
> Alternatively, was an error code intended in the bad length case, as is
> done in process_brxed_802_11_packet?

>   drivers/net/wireless/libertas/rx.c |    7 ++-----
>   1 file changed, 2 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
> index c7366b0..807c5b8 100644
> --- a/drivers/net/wireless/libertas/rx.c
> +++ b/drivers/net/wireless/libertas/rx.c
[...]
> @@ -154,10 +152,9 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
>   	else
>   		netif_rx_ni(skb);
>
> -	ret = 0;
>   done:
> -	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", ret);
> -	return ret;
> +	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", 0);

    Why not just "ret 0"?

> +	return 0;

WBR, Sergei
