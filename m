From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: fix memory leak on regd when chan is zero
Date: Thu, 15 Sep 2016 20:10:47 +0300
Message-ID: <87vaxx9jhk.fsf@kamboji.qca.qualcomm.com>
References: <20160915162117.1209-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160915162117.1209-1-colin.king@canonical.com> (Colin King's
        message of "Thu, 15 Sep 2016 17:21:17 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> When chan is zero mwifiex_create_custom_regdomain does not kfree
> regd and we have a memory leak. Fix this by freeing regd before
> the return.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
> index 3344a26..15a91f3 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
> +++ b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
> @@ -1049,8 +1049,10 @@ mwifiex_create_custom_regdomain(struct mwifiex_private *priv,
>  		enum nl80211_band band;
>  
>  		chan = *buf++;
> -		if (!chan)
> +		if (!chan) {
> +			kfree(regd);
>  			return NULL;
> +		}

Bob sent a similar fix and he also did more:

mwifiex: fix error handling in mwifiex_create_custom_regdomain

https://patchwork.kernel.org/patch/9331337/

-- 
Kalle Valo
