From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for SoC devices
Date: Mon, 27 Mar 2017 18:11:15 +0200
Message-ID: <1897671.fKa4XTnU1K@debian64>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        John Crispin <john@phrozen.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        m@kresin.me
To: Alban <albeu@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, March 13, 2017 10:05:09 PM CEST Alban wrote:
> The current binding only cover PCI devices so extend it for SoC devices.
> 
> Most SoC platforms use an MTD partition for the calibration data
> instead of an EEPROM. The qca,no-eeprom property was added to allow
> loading the EEPROM content using firmware loading. This new binding
> replace this hack with NVMEM cells, so we also mark the qca,no-eeprom
> property as deprecated in case anyone ever used it.

Please don't mark "qca,no-eeprom" as deprecated then.
If some devices geniously need to rely on userspace for extracting 
and processing the calibration data, it should be stay a
optional properties.

For example: A device that can't do easily without "qca,no-eeprom" is
the AVM FRITZ!WLAN Repeater 300E. For this device, the caldata 
is stored in the flash, however for whatever reason the vendor
choose to "reverse" it. (like completely back to front, not byteswapped
or something). So an extra "unreversing step" is required. So, it would
require some sort of a special nvmem-provider-processor as an 
alternative.

> Signed-off-by: Alban <albeu@free.fr>
> ---
> diff --git a/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt b/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
> index b7396c8..61f5f6d 100644
> --- a/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
> +++ b/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
> @@ -27,16 +27,34 @@ Required properties:
>  			- 0034 for AR9462
>  			- 0036 for AR9565
>  			- 0037 for AR9485
> +		For SoC devices the compatible should be "qca,<soctype>-wmac"
> +		and one of the following fallbacks:
> +			- "qca,ar9100-wmac"
> +			- "qca,ar9330-wmac"
> +			- "qca,ar9340-wmac"
> +			- "qca,qca9550-wmac"
> +			- "qca,qca9530-wmac"
>  - reg: Address and length of the register set for the device.
>  
> +Required properties for SoC devices:
> +- interrupt-parent: phandle of the parent interrupt controller.
> +- interrupts: Interrupt specifier for the controllers interrupt.
> +
>  Optional properties:
> +- mac-address: See ethernet.txt in the parent directory
> +- local-mac-address: See ethernet.txt in the parent directory
> +- clock-names: has to be "ref"
> +- clocks: phandle of the reference clock
> +- resets: phandle of the reset line
> +- nvmem-cell-names: has to be "eeprom" and/or "address"
> +- nvmem-cells: phandle to the eeprom nvmem cell and/or to the mac address
> +		nvmem cell.
> +
> +Deprecated properties:
>  - qca,no-eeprom: Indicates that there is no physical EEPROM connected to the
>  			ath9k wireless chip (in this case the calibration /
>  			EEPROM data will be loaded from userspace using the
>  			kernel firmware loader).
> -- mac-address: See ethernet.txt in the parent directory
> -- local-mac-address: See ethernet.txt in the parent directory
> -
It sounds like you want to deprecate mac-address and local-mac-address as well.
If so you sould add this to the commit as well. From my point of view, people
mostly flat-out patched the eeprom-image if they wanted to set the mac-address.
However, this was an extra step, if nvmem does away with it, I'm completely
fine with deprecating these properties.

Thanks,
Christian
