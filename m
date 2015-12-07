From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH v2] rtlwifi: fix memory leak for USB device
Date: Sun, 6 Dec 2015 20:14:21 -0600
Message-ID: <5664EB7D.7010009@lwfinger.net>
References: <1449446851-2221-1-git-send-email-peter@lekensteyn.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org
To: Peter Wu <peter@lekensteyn.nl>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449446851-2221-1-git-send-email-peter@lekensteyn.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/2015 06:07 PM, Peter Wu wrote:
> Free skb for received frames with a wrong checksum. This can happen
> pretty rapidly, exhausting all memory.
>
> This fixes a memleak (detected with kmemleak). Originally found while
> using monitor mode, but it also appears during managed mode (once the
> link is up).
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Peter Wu <peter@lekensteyn.nl>
> ---
>   v2: updated commit message based on Larry's feedback
>   v1: https://lkml.kernel.org/r/1449424677-3140-1-git-send-email-peter@lekensteyn.nl
>
> Tested with v4.3, rebased on v4.4-rc3 (changed paths). The bug goes back
> to its introduction in the v2.6.x kernel.
> ---
>   drivers/net/wireless/realtek/rtlwifi/usb.c | 2 ++
>   1 file changed, 2 insertions(+)

ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry

>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
> index 2721cf8..aac1ed3 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/usb.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
> @@ -531,6 +531,8 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
>   			ieee80211_rx(hw, skb);
>   		else
>   			dev_kfree_skb_any(skb);
> +	} else {
> +		dev_kfree_skb_any(skb);
>   	}
>   }
>
>
