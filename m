From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: Re: [PATCH] wlcore: consolidate kmalloc + memset 0 into kzalloc
Date: Tue, 22 Dec 2015 12:36:43 +0530
Message-ID: <CAFqt6zaYfbLqUDjcJ36TKMCXpy5_swjZQDj_75topDsMtfBRFA@mail.gmail.com>
References: <1450716464-20759-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>, Eliad Peller <eliad@wizery.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Arik Nemtsov <arik@wizery.com>,
	Tony Lindgren <tony@atomide.com>,
	Luciano Coelho <luca@coelho.fi>,
	Eyal Reizer <eyalreizer@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450716464-20759-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 21, 2015 at 10:17 PM, Nicholas Mc Guire <hofrat@osadl.org> wrote:
> This is an API consolidation only. The use of kmalloc + memset to 0
> is equivalent to kzalloc.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> ---
>
> Found by coccinelle script (relaxed version of
> scripts/coccinelle/api/alloc/kzalloc-simple.cocci)
>
> Patch was compile tested with: x86_64_defconfig +
> CONFIG_WL12XX=m (implies CONFIG_WLCORE=m)
>
> Patch is against linux-next (localversion-next is -next-20151221)
>
>  drivers/net/wireless/ti/wlcore/main.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
> index ec7f6af..dfc49bf 100644
> --- a/drivers/net/wireless/ti/wlcore/main.c
> +++ b/drivers/net/wireless/ti/wlcore/main.c
> @@ -838,7 +838,7 @@ static void wl12xx_read_fwlog_panic(struct wl1271 *wl)
>
>         wl1271_info("Reading FW panic log");
>
> -       block = kmalloc(wl->fw_mem_block_size, GFP_KERNEL);
> +       block = kzalloc(wl->fw_mem_block_size, GFP_KERNEL);
>         if (!block)
>                 return;
>
> @@ -885,7 +885,6 @@ static void wl12xx_read_fwlog_panic(struct wl1271 *wl)
>                         goto out;
>                 }
>
> -               memset(block, 0, wl->fw_mem_block_size);

Current code is reseting the block value to 0 in each iterations and
perform some operations.
But if you are using kzalloc as mentioned above it will memset 0 to
block pointer only once.
So both are not equivalent operations.

>                 ret = wlcore_read_hwaddr(wl, addr, block,
>                                         wl->fw_mem_block_size, false);
>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-Souptick
