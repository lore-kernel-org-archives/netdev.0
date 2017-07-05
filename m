From: Brian Norris <briannorris@chromium.org>
Subject: Re: [PATCH] mwifiex: uninit wakeup info when failed to add card
Date: Wed, 5 Jul 2017 11:08:15 -0700
Message-ID: <20170705180813.GA115427@google.com>
References: <1499068470-8022-1-git-send-email-jeffy.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, akarwar@marvell.com,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        netdev@vger.kernel.org
To: Jeffy Chen <jeffy.chen@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1499068470-8022-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2017 at 03:54:30PM +0800, Jeffy Chen wrote:
> We inited wakeup info at the beginning of mwifiex_add_card, so we need
> to uninit it in the error handling.
> 
> It's much the same as what we did in:
> 36908c4 mwifiex: uninit wakeup info when removing device

Yeah, I noticed I hadn't covered all the error cases, so your change is
part of the fix. But you're not covering the error paths when the
firmware doesn't load correctly -- this happens asynchronously to
mwifiex_add_card(). i.e., you need to fixup the error paths in
_mwifiex_fw_dpc() too.

Brian

> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
> 
> ---
> 
>  drivers/net/wireless/marvell/mwifiex/main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
> index f2600b8..17d2cbe 100644
> --- a/drivers/net/wireless/marvell/mwifiex/main.c
> +++ b/drivers/net/wireless/marvell/mwifiex/main.c
> @@ -1655,6 +1655,8 @@ mwifiex_add_card(void *card, struct completion *fw_done,
>  		mwifiex_shutdown_drv(adapter);
>  	}
>  err_kmalloc:
> +	if (adapter->irq_wakeup >= 0)
> +		device_init_wakeup(adapter->dev, false);
>  	mwifiex_free_adapter(adapter);
>  
>  err_init_sw:
> -- 
> 2.1.4
> 
> 
