From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: btcoexist: adjust double test
Date: Tue, 12 Aug 2014 17:14:31 -0500
Message-ID: <53EA91C7.5010103@lwfinger.net>
References: <20140812193929.GA4233@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr
To: Himangi Saraogi <himangi774@gmail.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:33627 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbaHLWOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:14:33 -0400
In-Reply-To: <20140812193929.GA4233@himangi-Dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2014 02:39 PM, Himangi Saraogi wrote:
> Rewrite a duplicated test to test the correct value
> 
> The Coccinelle semantic patch that finds this problem is:
> 
> // <smpl>
> @@
> expression E;
> @@
> 
> (
> * E
>   || ... || E
> |
> * E
>   && ... && E
> )
> // </smpl>
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> ---
> In file drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c, there is a
> similar function that tests for WIRELESS_MODE_G and WIRELESS_MODE_B.
> I have not tested the code, so you am not sure whether it is the
> correct solution.
> 
>  drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
> index 33da3df..d4bd550 100644
> --- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
> +++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
> @@ -101,7 +101,7 @@ static bool halbtc_legacy(struct rtl_priv *adapter)
>  
>  	bool is_legacy = false;
>  
> -	if ((mac->mode == WIRELESS_MODE_B) || (mac->mode == WIRELESS_MODE_B))
> +	if ((mac->mode == WIRELESS_MODE_B) || (mac->mode == WIRELESS_MODE_G))
>  		is_legacy = true;
>  
>  	return is_legacy;

The latest version of the vendor driver has this change already applied.

Acked-by: Larry.Finger <Larry.Finger@lwfinger.net>

Larry
