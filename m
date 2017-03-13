From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 3/7] ath9k: Add support for reading the EEPROM data using
 the nvmem API
Date: Mon, 13 Mar 2017 23:17:05 +0100
Message-ID: <97965050-1f44-b779-541e-4b67665e1d1c@gmail.com>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
 <1489439116-4233-3-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Crispin <john@phrozen.org>, Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alban <albeu@free.fr>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34586 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdCMWRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:17:11 -0400
In-Reply-To: <1489439116-4233-3-git-send-email-albeu@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2017 10:05 PM, Alban wrote:
> @@ -654,6 +656,25 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
>  	if (ret)
>  		return ret;
>
> +	/* If the EEPROM hasn't been retrieved via firmware request
> +	 * use the nvmem API insted.
> +	 */
> +	if (!ah->eeprom_blob) {
> +		struct nvmem_cell *eeprom_cell;
> +
> +		eeprom_cell = nvmem_cell_get(ah->dev, "eeprom");
> +		if (!IS_ERR(eeprom_cell)) {
> +			ah->eeprom_data = nvmem_cell_read(
> +				eeprom_cell, &ah->eeprom_size);
> +			nvmem_cell_put(eeprom_cell);
> +
> +			if (IS_ERR(ah->eeprom_data)) {
> +				dev_err(ah->dev, "failed to read eeprom");

One trivial thing: missing line break.


> +				return PTR_ERR(ah->eeprom_data);
> +			}
> +		}
> +	}
> +
>  	if (ath9k_led_active_high != -1)
>  		ah->config.led_active_high = ath9k_led_active_high == 1;
