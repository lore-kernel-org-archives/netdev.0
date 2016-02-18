From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] mwifiex: Use to_delayed_work()
Date: Thu, 18 Feb 2016 11:55:36 +1100
Message-ID: <CAGRGNgXSuYSGAdY1XxA6d0ro0doDWvgJmNpD15ASGXDTxCmVEA@mail.gmail.com>
References: <20160217123336.GA30230@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38902 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965753AbcBRAz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 19:55:56 -0500
In-Reply-To: <20160217123336.GA30230@amitoj-Inspiron-3542>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Wed, Feb 17, 2016 at 11:33 PM, Amitoj Kaur Chawla
<amitoj1606@gmail.com> wrote:
> Introduce the use of to_delayed_work() helper function instead of open
> coding it with container_of()
>
> A simplified version of the Coccinelle semantic patch used to make
> this change is:
>
> //<smpl>
> @@
> expression a;
> symbol work;
> @@
> - container_of(a, struct delayed_work, work)
> + to_delayed_work(a)
> //</smpl>
>
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

> ---
>  drivers/net/wireless/marvell/mwifiex/11h.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/marvell/mwifiex/11h.c b/drivers/net/wireless/marvell/mwifiex/11h.c
> index 71a1b58..81c60d0 100644
> --- a/drivers/net/wireless/marvell/mwifiex/11h.c
> +++ b/drivers/net/wireless/marvell/mwifiex/11h.c
> @@ -123,8 +123,7 @@ void mwifiex_11h_process_join(struct mwifiex_private *priv, u8 **buffer,
>  void mwifiex_dfs_cac_work_queue(struct work_struct *work)
>  {
>         struct cfg80211_chan_def chandef;
> -       struct delayed_work *delayed_work =
> -                       container_of(work, struct delayed_work, work);
> +       struct delayed_work *delayed_work = to_delayed_work(work);
>         struct mwifiex_private *priv =
>                         container_of(delayed_work, struct mwifiex_private,
>                                      dfs_cac_work);
> @@ -289,8 +288,7 @@ int mwifiex_11h_handle_radar_detected(struct mwifiex_private *priv,
>  void mwifiex_dfs_chan_sw_work_queue(struct work_struct *work)
>  {
>         struct mwifiex_uap_bss_param *bss_cfg;
> -       struct delayed_work *delayed_work =
> -                       container_of(work, struct delayed_work, work);
> +       struct delayed_work *delayed_work = to_delayed_work(work);
>         struct mwifiex_private *priv =
>                         container_of(delayed_work, struct mwifiex_private,
>                                      dfs_chan_sw_work);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
