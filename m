From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH V5 2/2] brcmfmac: don't warn user about NVRAM if fallback
 to the platform one succeeds
Date: Tue, 1 Aug 2017 23:20:32 +0200
Message-ID: <d50d2577-b9d3-27f1-6e3d-8e0dc4ec2024@broadcom.com>
References: <20170731150945.8925-1-zajec5@gmail.com>
 <20170731150945.8925-2-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        Daniel Wagner <wagi@monom.org>,
        David Woodhouse <dwmw2@infradead.org>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>, yi1.li@linux.intel.com,
        atull@kernel.org, Moritz Fischer <moritz.fischer@ettus.com>,
        pmladek@suse.com, Johannes Berg <johannes.berg@intel.com>,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        Kalle Valo <kvalo@codeaurora.org>, luto@kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Howells <dhowells@redhat.com>, pjones@redhat.com,
        Hans de Goede <hdegoede@redhat.com>, alan@linux.intel.com,
        tytso@mit.edu, lkml <linux-kernel@vger.kernel.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@b
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731150945.8925-2-zajec5@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31-07-17 17:09, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> Failing to load NVRAM *file* isn't critical if we manage to get platform
> NVRAM in the fallback path. It means warnings like:
> [   10.801506] brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac43602-pcie.txt failed with error -2
> are unnecessary & disturbing for people with *platform* NVRAM as they
> are not expected to have NVRAM file. This is a very common case for
> Broadcom home routers.
> 
> Instead of printing warning immediately within the firmware subsystem
> let's try our fallback code first. If that fails as well, then it's a
> right moment to print an error.
> 
> This should reduce amount of false reports from users seeing this
> warning while having wireless working perfectly fine with the platform
> NVRAM.

Reviewed-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
> ---
> V2: Update commit message as it wasn't clear enough (thanks Andy) & add extra
>     messages to the firmware.c.
> V3: Set FW_OPT_UEVENT to don't change behavior
> V4: Switch to the new request_firmware_async syntax
> V5: Rebase, update commit message, resend after drvdata discussion
> ---
>  .../wireless/broadcom/brcm80211/brcmfmac/firmware.c    | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
> index d231042f19d6..524442b3870f 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
> @@ -462,8 +462,14 @@ static void brcmf_fw_request_nvram_done(const struct firmware *fw, void *ctx)
>  		raw_nvram = false;
>  	} else {
>  		data = bcm47xx_nvram_get_contents(&data_len);
> -		if (!data && !(fwctx->flags & BRCMF_FW_REQ_NV_OPTIONAL))
> -			goto fail;
> +		if (!data) {
> +			brcmf_dbg(TRACE, "Failed to get platform NVRAM\n");

Better make this INFO level instead of TRACE. The intent of TRACE level
is for entry/exit points in functions.

Regards,
Arend
