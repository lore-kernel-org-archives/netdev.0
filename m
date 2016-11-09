From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH] mwifiex: fix memory leak in
 mwifiex_save_hidden_ssid_channels()
Date: Wed, 9 Nov 2016 08:53:40 +0000
Message-ID: <afaba6dcd5e845118be806ffd7bbe511@SC-EXCH04.marvell.com>
References: <1478662648-70698-1-git-send-email-jcliang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Nishant Sarmukadam <nishants@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "open list:MARVELL MWIFIEX WIRELESS DRIVER"
        <linux-wireless@vger.kernel.org>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Ricky Liang <jcliang@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478662648-70698-1-git-send-email-jcliang@chromium.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Ricky Liang [mailto:jcliang@chromium.org]
> Sent: Wednesday, November 09, 2016 9:07 AM
> Cc: Ricky Liang; Amitkumar Karwar; Nishant Sarmukadam; Kalle Valo; open
> list:MARVELL MWIFIEX WIRELESS DRIVER; open list:NETWORKING DRIVERS; open
> list
> Subject: [PATCH] mwifiex: fix memory leak in
> mwifiex_save_hidden_ssid_channels()
> 
> kmemleak reports memory leak in mwifiex_save_hidden_ssid_channels():
> 
> unreferenced object 0xffffffc0a2914780 (size 192):
>   comm "ksdioirqd/mmc2", pid 2004, jiffies 4307182506 (age 820.684s)
>   hex dump (first 32 bytes):
>     00 06 47 49 4e 2d 32 67 01 03 c8 60 6c 03 01 40  ..GIN-2g...`l..@
>     07 10 54 57 20 34 04 1e 64 05 24 84 03 24 95 04  ..TW 4..d.$..$..
>   backtrace:
>     [<ffffffc0003375f4>] create_object+0x164/0x2b4
>     [<ffffffc0008e3530>] kmemleak_alloc+0x50/0x88
>     [<ffffffc000335120>] __kmalloc_track_caller+0x1bc/0x264
>     [<ffffffc00030899c>] kmemdup+0x38/0x64
>     [<ffffffbffc2311cc>] mwifiex_fill_new_bss_desc+0x3c/0x130 [mwifiex]
>     [<ffffffbffc22ee9c>] mwifiex_save_curr_bcn+0x4ec/0x640 [mwifiex]
>     [<ffffffbffc22f45c>]
> mwifiex_handle_event_ext_scan_report+0x1d4/0x268 [mwifiex]
>     [<ffffffbffc2375d0>] mwifiex_process_sta_event+0x378/0x898 [mwifiex]
>     [<ffffffbffc224dc8>] mwifiex_process_event+0x1a8/0x1e8 [mwifiex]
>     [<ffffffbffc2228f0>] mwifiex_main_process+0x258/0x534 [mwifiex]
>     [<ffffffbffc258858>] 0xffffffbffc258858
>     [<ffffffc00071ee90>] process_sdio_pending_irqs+0xf8/0x160
>     [<ffffffc00071efdc>] sdio_irq_thread+0x9c/0x1a4
>     [<ffffffc000240d08>] kthread+0xf4/0x100
>     [<ffffffc0002043fc>] ret_from_fork+0xc/0x50
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> Signed-off-by: Ricky Liang <jcliang@chromium.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/scan.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/scan.c
> b/drivers/net/wireless/marvell/mwifiex/scan.c
> index 97c9765..98ce072 100644
> --- a/drivers/net/wireless/marvell/mwifiex/scan.c
> +++ b/drivers/net/wireless/marvell/mwifiex/scan.c
> @@ -1671,6 +1671,10 @@ static int
> mwifiex_save_hidden_ssid_channels(struct mwifiex_private *priv,
>  	}
> 
>  done:
> +	/* beacon_ie buffer was allocated in function
> +	 * mwifiex_fill_new_bss_desc(). Free it now.
> +	 */
> +	kfree(bss_desc->beacon_buf);
>  	kfree(bss_desc);
>  	return 0;
>  }

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
