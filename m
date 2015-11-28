From: Brent Taylor <motobud@gmail.com>
Subject: Re: [PATCH] ath6kl: Use vmalloc for loading firmware using api1 method
Date: Sat, 28 Nov 2015 12:58:30 -0600
Message-ID: <CAP+RiCA6wasaiMCYEJ-8gaiVMi5JP2JT6A1bGm9nHJ9CA+Ow5g@mail.gmail.com>
References: <1444972259-24260-1-git-send-email-motobud@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ath6kl@lists.infradead.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444972259-24260-1-git-send-email-motobud@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, the first e-mail was sent via gmail and I forgot about sending
it in plain text mode.

Whats the status on this patch?  I don't see it on patchwork anymore
nor is it in any of the git trees I checked.

Thanks,
Brent

On Fri, Oct 16, 2015 at 12:10 AM, Brent Taylor <motobud@gmail.com> wrote:
> Signed-off-by: Brent Taylor <motobud@gmail.com>
> ---
>  drivers/net/wireless/ath/ath6kl/init.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
> index 6e473fa..2155739 100644
> --- a/drivers/net/wireless/ath/ath6kl/init.c
> +++ b/drivers/net/wireless/ath/ath6kl/init.c
> @@ -673,10 +673,17 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
>                 return ret;
>
>         *fw_len = fw_entry->size;
> -       *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
> -
> -       if (*fw == NULL)
> -               ret = -ENOMEM;
> +       if (&ar->fw == fw) {
> +               *fw = vmalloc(fw_entry->size);
> +               if (*fw == NULL)
> +                       ret = -ENOMEM;
> +               else
> +                       memcpy(*fw, fw_entry->data, fw_entry->size);
> +       } else {
> +               *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
> +               if (*fw == NULL)
> +                       ret = -ENOMEM;
> +       }
>
>         release_firmware(fw_entry);
>
> --
> 2.6.1
>
