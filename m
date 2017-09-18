From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 net 2/3] lan78xx: Allow EEPROM write for less than
 MAX_EEPROM_SIZE
Date: Mon, 18 Sep 2017 22:29:51 +0300
Message-ID: <17bc270e-9cc1-485a-d6bb-0ebfa143e65e@cogentembedded.com>
References: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
 <20170918220225.3767-3-Nisar.Sayed@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: UNGLinuxDriver@microchip.com, netdev@vger.kernel.org
To: Nisar Sayed <Nisar.Sayed@microchip.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:54467 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750872AbdIRT3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:29:55 -0400
Received: by mail-lf0-f42.google.com with SMTP id k23so1582610lfi.11
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:29:54 -0700 (PDT)
In-Reply-To: <20170918220225.3767-3-Nisar.Sayed@microchip.com>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 09/19/2017 01:02 AM, Nisar Sayed wrote:

> Allow EEPROM write for less than MAX_EEPROM_SIZE
> 
> Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
> Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> ---
>   drivers/net/usb/lan78xx.c | 9 ++++-----
>   1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index fcf85ae37435..3292f56ffe02 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -1290,11 +1290,10 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
>   	if (ret)
>   		return ret;
>   
> -	/* Allow entire eeprom update only */
> -	if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
> -	    (ee->offset == 0) &&
> -	    (ee->len == 512) &&
> -	    (data[0] == EEPROM_INDICATOR))
> +	/* Invalid EEPROM_INDICATOR at offset zero will result in fail to

    s/fail/a failure/.

> +	 * load data from EEPROM
> +	 */
> +	if (ee->magic == LAN78XX_EEPROM_MAGIC)
>   		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
>   	else if ((ee->magic == LAN78XX_OTP_MAGIC) &&
>   		 (ee->offset == 0) &&
> 

MBR, Sergei
