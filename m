From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8822be: Fix typo for CONFIG_RTLWIFI_DEBUG
Date: Tue, 29 Aug 2017 09:10:10 -0500
Message-ID: <fcab4e04-be42-5a05-c5ad-4947d2d41164@lwfinger.net>
References: <20170829112643.GA14571@kroah.com>
 <1504006208-18965-1-git-send-email-andreas.ziegler@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 Birming Chiu <birming@realtek.com>, netdev <netdev@vger.kernel.org>,
 Steven Ting <steventing@realtek.com>
To: Andreas Ziegler <andreas.ziegler@fau.de>,
 Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1504006208-18965-1-git-send-email-andreas.ziegler@fau.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 08/29/2017 06:30 AM, Andreas Ziegler wrote:
> The debugging output in deinit_priv is guarded by an  #ifdef using
> CONFIG_RTL_DEBUG. This symbol does not exist and should be
> CONFIG_RTLWIFI_DEBUG instead.
> 
> Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>

NACK.

Yes, there is a problem; however, CONFIG_RTLWIFI_DEBUG is not the value that 
should be used. That one is reserved for the non-staging drivers in 
drivers/net/wireless/realtek/rtlwifi/. The correct symbol for r8822be is 
CONFIG_RTLWIFI_DEBUG_ST.

Larry

> ---
>   drivers/staging/rtlwifi/halmac/rtl_halmac.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/rtlwifi/halmac/rtl_halmac.c b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
> index 031bf2c..888ca43 100644
> --- a/drivers/staging/rtlwifi/halmac/rtl_halmac.c
> +++ b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
> @@ -386,7 +386,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
>   		u32 count, size;
>   
>   		count = HALMAC_FEATURE_ALL + 1;
> -#ifdef CONFIG_RTL_DEBUG
> +#ifdef CONFIG_RTLWIFI_DEBUG
>   		{
>   			struct submit_ctx *sctx;
>   			u32 i;
> @@ -405,7 +405,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
>   				rtl_mfree((u8 *)sctx, sizeof(*sctx));
>   			}
>   		}
> -#endif /* !CONFIG_RTL_DEBUG */
> +#endif /* !CONFIG_RTLWIFI_DEBUG */
>   		size = sizeof(*indicator) * count;
>   		kfree((u8 *)indicator);
>   	}
> 
