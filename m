From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] net-iwlegacy: One check less in il_eeprom_init()
 after error detection
Date: Sat, 2 Jan 2016 02:13:07 +0300
Message-ID: <56870803.7010807@cogentembedded.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686E13F.2010309@users.sourceforge.net>
 <5686E21E.4090901@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5686E21E.4090901@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/1/2016 11:31 PM, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 21:12:29 +0100
>
> This issue was detected by using the Coccinelle software.
>
> Adjust a jump target to avoid a check repetition before the function
> call "il_eeprom_free".

    One question: why?

>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>   drivers/net/wireless/intel/iwlegacy/common.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/intel/iwlegacy/common.c b/drivers/net/wireless/intel/iwlegacy/common.c
> index c3afaf7..ae45fd3 100644
> --- a/drivers/net/wireless/intel/iwlegacy/common.c
> +++ b/drivers/net/wireless/intel/iwlegacy/common.c
[...]
> @@ -772,9 +772,11 @@ il_eeprom_init(struct il_priv *il)
>   done:
>   	il->ops->eeprom_release_semaphore(il);
>
> -err:
> -	if (ret)
> +	if (ret) {
> +free_eeprom:

    This is ugly, I'd say.

[...]

MBR, Sergei
