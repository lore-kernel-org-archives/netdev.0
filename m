From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] airo: Implement netif_carrier_on/off
Date: Wed, 16 Sep 2015 17:30:22 +0300
Message-ID: <55F97CFE.3020806@cogentembedded.com>
References: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
 <1442330289-2907-2-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>,
	Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:35189 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbbIPOaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 10:30:25 -0400
Received: by lagj9 with SMTP id j9so132400807lag.2
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 07:30:23 -0700 (PDT)
In-Reply-To: <1442330289-2907-2-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/15/2015 6:18 PM, Ondrej Zary wrote:

> Add calls to netif_carrier_on and netif_carrier_off
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>   drivers/net/wireless/airo.c |    6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index a8f2767..629245c 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
[...]
> @@ -3277,7 +3278,9 @@ static void airo_handle_link(struct airo_info *ai)
>   		eth_zero_addr(wrqu.ap_addr.sa_data);
>   		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
>   		wireless_send_event(ai->dev, SIOCGIWAP, &wrqu, NULL);
> -	}
> +		netif_carrier_off(ai->dev);
> +	} else
> +		netif_carrier_off(ai->dev);

    Need {} in all branches, according the the Documentation/CodingStyle.

>   }
>
>   static void airo_handle_rx(struct airo_info *ai)
[...]

MBR, Sergei
