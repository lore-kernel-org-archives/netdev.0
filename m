From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 3/3] p54: use request_firmware_direct() for optional EEPROM
 override
Date: Wed, 25 Jun 2014 09:26:23 +0200
Message-ID: <53AA799F.7030807@broadcom.com>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com> <1403649583-12707-4-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<gregkh@linuxfoundation.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	<linux-wireless@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, <tiwai@suse.de>,
	<chunkeey@googlemail.com>, <leedom@chelsio.com>,
	<cocci@systeme.lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403649583-12707-4-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-06-14 00:39, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> The p54 driver uses request_firmware() twice, once for actual
> firmware and then another time for an optional user overide on
> EEPROM, 3826.eeprom. The custom EEPROM  is optional but if not
> present we'll introduce an extra lag of 60 seconds with udev
> present. Annotate we don't want udev nonsense here to avoid
> the lag in case its not present.

I guess the fact that EEPROM is optional does not matter much. If doing 
a second request you could always use request_firmware_direct(), right?

Regards,
Arend

> This was found with the following SmPL patch.
>
> @ firmware_not_critical @
> expression cf;
> expression config_file;
> expression dev;
> int ret;
> identifier l;
> statement S;
> @@
>
> -	ret = request_firmware(&cf, config_file, dev);
> +	ret = request_firmware_direct(&cf, config_file, dev);
> 	if (ret < 0) {
> 		... when != goto l;
> 		    when != return ret;
> 		    when any
> 	} else {
> 		...
> 		release_firmware(cf);
> 		...
> 	}
>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: Christian Lamparter <chunkeey@googlemail.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: cocci@systeme.lip6.fr
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>   drivers/net/wireless/p54/p54spi.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
> index de15171..63de5ee 100644
> --- a/drivers/net/wireless/p54/p54spi.c
> +++ b/drivers/net/wireless/p54/p54spi.c
> @@ -193,7 +193,7 @@ static int p54spi_request_eeprom(struct ieee80211_hw *dev)
>   	/* allow users to customize their eeprom.
>   	 */
>
> -	ret = request_firmware(&eeprom, "3826.eeprom", &priv->spi->dev);
> +	ret = request_firmware_direct(&eeprom, "3826.eeprom", &priv->spi->dev);
>   	if (ret < 0) {
>   #ifdef CONFIG_P54_SPI_DEFAULT_EEPROM
>   		dev_info(&priv->spi->dev, "loading default eeprom...\n");
>
