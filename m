From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] net:wireless:Add proper locking for the function, b43_op_beacon_set_tim
 in main.c
Date: Sun, 25 Jan 2015 10:51:49 -0600
Message-ID: <54C51F25.9050602@lwfinger.net>
References: <1422169574-8451-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, kvalo@codeaurora.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422169574-8451-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/25/2015 01:06 AM, Nicholas Krause wrote:
> Adds proper locking for the function, b43_op_beacon_set_tim in main.c that internally calls b43_update_templates.
> Due to the function that is being called internally,b43_update_templates needing the mutex lock of the structure
> pointer wl passed  it to run successfully and without issues we add the calls to mutex_lock before and mutex_unlock
> after it's call internally in b43_op_beacon_set_tim in order to allow the function,,b43_update_templates to run
> successfully and without issues related to concurrent access.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>   drivers/net/wireless/b43/main.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
> index 47731cb..b807958 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -5094,8 +5094,9 @@ static int b43_op_beacon_set_tim(struct ieee80211_hw *hw,
>   {
>   	struct b43_wl *wl = hw_to_b43_wl(hw);
>
> -	/* FIXME: add locking */
> +	mutex_lock(&wl->mutex);
>   	b43_update_templates(wl);
> +	mutex_unlock(&wl->mutex);
>
>   	return 0;
>   }

Nicolas,

You must be an idiot for resubmitting this patch after Michael Busch clearly 
told you that this patch can *never* work as we are in atomic context here! If 
you are looking for patch credits, submitting one that messes with locking *that 
you have never tested* will certainly get you notoriety on the Internet, but I 
doubt that you want that bad a reputation!!

NACK.

Larry
