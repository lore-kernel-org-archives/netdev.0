From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 1/5] wlcore: Use common error handling code in wlcore_nvs_cb()
Date: Tue, 31 Oct 2017 00:28:43 +1100
Message-ID: <CAGRGNgULQRFo7T2TKr_=xNY9csYXTnnPc4k1AjS2OQ20zg+cbA@mail.gmail.com>
References: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net> <7b40d50f-cdac-bd47-5070-894140f7ceb3@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Eyal Reizer <eyalr@ti.com>, Iain Hunter <drhunter95@gmail.com>,
        James Minor <james.minor@ni.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maxim Altshul <maxim.altshul@ti.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7b40d50f-cdac-bd47-5070-894140f7ceb3@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On Mon, Oct 30, 2017 at 7:11 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 29 Oct 2017 18:38:04 +0100
>
> Add a jump target so that a bit of exception handling can be better reused
> at the end of this function.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/wireless/ti/wlcore/main.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
> index c346c021b999..48380d48ef09 100644
> --- a/drivers/net/wireless/ti/wlcore/main.c
> +++ b/drivers/net/wireless/ti/wlcore/main.c
> @@ -6551,6 +6549,11 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
>  out:
>         release_firmware(fw);
>         complete_all(&wl->nvs_loading_complete);
> +       return;
> +
> +power_off:

Name this "out_power_off" to match the other labels.

> +       wl1271_power_off(wl);
> +       goto out_free_nvs;

Why not put this in front of the out_free_nvs label? It looks weird here.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
