From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3.16]r8169: Implement definitions from
 linux/mii.h header
Date: Fri, 25 Mar 2016 14:46:03 +0300
Message-ID: <56F524FB.5080202@cogentembedded.com>
References: <1458901517-5932-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36061 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcCYLqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 07:46:07 -0400
Received: by mail-lf0-f45.google.com with SMTP id d82so53745625lfe.3
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 04:46:06 -0700 (PDT)
In-Reply-To: <1458901517-5932-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/25/2016 1:25 PM, Corcodel Marian wrote:

>   Add definitions from mii and inhibit 0 to advertise.
>
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>   drivers/net/ethernet/realtek/r8169.c | 22 ++++++----------------
>   1 file changed, 6 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index a57b650..a450656 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1679,29 +1679,19 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>   		int auto_nego;
>
>   		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
> -		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
> -				ADVERTISE_100HALF | ADVERTISE_100FULL);
> -
> -		if (adv & ADVERTISED_10baseT_Half)
> -			auto_nego |= ADVERTISE_10HALF;
> -		if (adv & ADVERTISED_10baseT_Full)
> -			auto_nego |= ADVERTISE_10FULL;
> -		if (adv & ADVERTISED_100baseT_Half)
> -			auto_nego |= ADVERTISE_100HALF;
> -		if (adv & ADVERTISED_100baseT_Full)
> -			auto_nego |= ADVERTISE_100FULL;
> +		auto_nego &= ~(0 | ADVERTISE_10HALF | ADVERTISE_10FULL |

    ORing with 0 doesn't change the result.

> +				ADVERTISE_100HALF | ADVERTISE_100FULL |
> +				ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
>
> +		auto_nego |= ethtool_adv_to_mii_adv_t(adv);
>   		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
>
>   		giga_ctrl = rtl_readphy(tp, MII_CTRL1000);
> -		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
> +		giga_ctrl &= ~(0 | ADVERTISE_1000FULL | ADVERTISE_1000HALF);

    Likewise.

[...]

MBR, Sergei
