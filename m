From: Eliad Peller <eliad@wizery.com>
Subject: Re: [PATCH v2 05/15] net: wireless: ti: Return flow can be simplified
 for wl1271_cmd_interrogate
Date: Thu, 22 Oct 2015 09:54:18 +0300
Message-ID: <CAB3XZEfGy4_WS-v5KAXWRfCRW5aBy5P2-HX6YXoEdSgf_FLRWw@mail.gmail.com>
References: <1445454428-12331-1-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, jslaby@suse.cz,
	lkp@intel.com
To: Punit Vara <punitvara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445454428-12331-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 10:07 PM, Punit Vara <punitvara@gmail.com> wrote:
> Remove int ret suggested by kbuild test robot
>
> This patch is to the wlcore/acx.c file that fixes up warning
> reported by coccicheck:
>
> WARNING: end returns can be simplified if negative or 0 value
>
> Prefer direct return value instead of writing 2-3 more sentence.
>
> Signed-off-by: Punit Vara <punitvara@gmail.com>
> ---
>  drivers/net/wireless/ti/wlcore/acx.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
> index f28fa3b..6b566d9 100644
> --- a/drivers/net/wireless/ti/wlcore/acx.c
> +++ b/drivers/net/wireless/ti/wlcore/acx.c
> @@ -158,16 +158,11 @@ out:
>  int wl1271_acx_mem_map(struct wl1271 *wl, struct acx_header *mem_map,
>                        size_t len)
>  {
> -       int ret;
>
>         wl1271_debug(DEBUG_ACX, "acx mem map");
>
> -       ret = wl1271_cmd_interrogate(wl, ACX_MEM_MAP, mem_map,
> +       return wl1271_cmd_interrogate(wl, ACX_MEM_MAP, mem_map,
>                                      sizeof(struct acx_header), len);
> -       if (ret < 0)
> -               return ret;
> -
> -       return 0;
>  }
>
this changes the return value in case of positive values.
have you verified it can't happen / won't affect the code flow?
i'm not sure you really want to blindly patch it...

Eliad.
