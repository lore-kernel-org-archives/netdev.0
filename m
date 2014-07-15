From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: rtl8192ee: Fix setting highest n rate
Date: Tue, 15 Jul 2014 12:06:34 -0700
Message-ID: <20140715190634.GA16330@kroah.com>
References: <1405396592-909-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1405396592-909-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 14, 2014 at 10:56:32PM -0500, Larry Finger wrote:
> Commit 4fb6a37c3f94c1cb4b828bfcc4347771e1628f88 by Andrey Utkin
> <andrey.krieger.utkin@gmail.com> and entitled "staging: rtl8192ee:
> "Correct bitmask in comparsion" fixed what appeared to be a typo. After
> consultation with the Realtek engineers, merely testing for a 2T2R device
> is sufficient to ensure that the TX MCS map will equal 0x0c, thus the second
> test can be ignored.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/staging/rtl8192ee/base.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/rtl8192ee/base.c b/drivers/staging/rtl8192ee/base.c
> index 71ed12e..b8b897a 100644
> --- a/drivers/staging/rtl8192ee/base.c
> +++ b/drivers/staging/rtl8192ee/base.c
> @@ -826,8 +826,7 @@ static u8 _rtl_get_vht_highest_n_rate(struct ieee80211_hw *hw,
>  	u8 hw_rate;
>  	u16 map = le16_to_cpu(sta->vht_cap.vht_mcs.tx_mcs_map);
>  
> -	if ((get_rf_type(rtlphy) == RF_2T2R) &&
> -	    (map & 0x000c) != 0x000c) {
> +	if ((get_rf_type(rtlphy) == RF_2T2R) {

I don't think you test built this change :(
