From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH V2] wireless: rtlwifi: Replace variable with a brake
Date: Sun, 22 Sep 2013 23:56:38 +0400
Message-ID: <523F4B76.80507@cogentembedded.com>
References: <1379879410-22787-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379879410-22787-1-git-send-email-peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/22/2013 11:50 PM, Peter Senna Tschudin wrote:

    You have a typo in the subject -- "brake" is a device to stop a vehicle. :-)

> This patch removes the variable continual, and change the while loop
> to break when efuse_data == 0xFF.

> Tested by compilation only.

> CC: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> Changes from V1:
>   - Fix the indetation
>   - Remove remaining } from removed else

> Please ignore the patch:
> [PATCH 12/19] wireless: Change variable type to bool

> And apply this one instead.

> The variable continual was declared as int, but was used as bool. I
> sent previous patch changing the variable type to bool, but Joe Perches
> proposed that removing the variable and adding a brake would be better.

>   drivers/net/wireless/rtlwifi/efuse.c | 18 ++++++++----------
>   1 file changed, 8 insertions(+), 10 deletions(-)

> diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
> index 838a1ed..2aedd9f 100644
> --- a/drivers/net/wireless/rtlwifi/efuse.c
> +++ b/drivers/net/wireless/rtlwifi/efuse.c
> @@ -1203,20 +1203,18 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
>
>   static u16 efuse_get_current_size(struct ieee80211_hw *hw)
>   {
> -	int continual = true;
>   	u16 efuse_addr = 0;
>   	u8 hworden;
>   	u8 efuse_data, word_cnts;
>
> -	while (continual && efuse_one_byte_read(hw, efuse_addr, &efuse_data)
> -	       && (efuse_addr < EFUSE_MAX_SIZE)) {
> -		if (efuse_data != 0xFF) {
> -			hworden = efuse_data & 0x0F;
> -			word_cnts = efuse_calculate_word_cnts(hworden);
> -			efuse_addr = efuse_addr + (word_cnts * 2) + 1;
> -		} else {
> -			continual = false;
> -		}
> +	while (efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
> +					(efuse_addr < EFUSE_MAX_SIZE)) {

    Start this line under efuse_one_byte_read, please. Also, parens are not 
needed.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
