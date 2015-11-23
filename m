From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] libertas: fix possible NULL dereference
Date: Tue, 24 Nov 2015 01:43:38 +0200
Message-ID: <CAHp75Veb4UBKrGsODoKnZrvOZUTEm78yBvhmBRn68oZYRecdQA@mail.gmail.com>
References: <1448281922-20382-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	libertas-dev@lists.infradead.org,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36402 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbbKWXnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:43:39 -0500
In-Reply-To: <1448281922-20382-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 2:32 PM, Sudip Mukherjee
<sudipm.mukherjee@gmail.com> wrote:
> We were dereferencing cmd first and checking for NULL later. Lets first
> check for NULL.

However the patch is valid due to reducing error prone part, the
commit message seems wrong.
There is no dereferencing, it is a simple pointer arithmetic.

>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>  drivers/net/wireless/marvell/libertas/cfg.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/marvell/libertas/cfg.c b/drivers/net/wireless/marvell/libertas/cfg.c
> index 8317afd..e38ad1d 100644
> --- a/drivers/net/wireless/marvell/libertas/cfg.c
> +++ b/drivers/net/wireless/marvell/libertas/cfg.c
> @@ -1108,7 +1108,7 @@ static int lbs_associate(struct lbs_private *priv,
>         size_t len, resp_ie_len;
>         int status;
>         int ret;
> -       u8 *pos = &(cmd->iebuf[0]);
> +       u8 *pos;
>         u8 *tmp;
>
>         lbs_deb_enter(LBS_DEB_CFG80211);
> @@ -1117,6 +1117,7 @@ static int lbs_associate(struct lbs_private *priv,
>                 ret = -ENOMEM;
>                 goto done;
>         }
> +       pos = &cmd->iebuf[0];
>
>         /*
>          * cmd              50 00
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
