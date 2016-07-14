From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 14:35:59 +0300
Message-ID: <d7474fed-89cb-1089-5b52-f8964cd7f840@cogentembedded.com>
References: <1468491528-17515-1-git-send-email-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Philipp Zabel <p.zabel@pengutronix.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33589 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbcGNLgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 07:36:03 -0400
Received: by mail-lf0-f50.google.com with SMTP id b199so61147087lfe.0
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 04:36:02 -0700 (PDT)
In-Reply-To: <1468491528-17515-1-git-send-email-p.zabel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/14/2016 1:18 PM, Philipp Zabel wrote:

> We can't detect the FXEN (fiber mode) bootstrap pin, so configure
> it via a boolean device tree property "fxen". If it is enabled,
> auto-negotiation is not supported. The only available modes are
> 100base-fx (full duplex and half duplex).
>
> Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
> ---
> I didn't see a way to reliably detect whether the PHY is set to fiber
> mode in the datasheet [1], so this patch adds a device tree property
> to enforce fiber mode (disable auto-negotiation, set speed to 100).
>
> [1] http://ww1.microchip.com/downloads/en/DeviceDoc/ksz8041tl-ftl-mll.pdf
> ---
>  .../devicetree/bindings/net/micrel-ksz8041.txt     | 24 ++++++++++++++++
>  drivers/net/phy/micrel.c                           | 32 ++++++++++++++++++++--
>  include/linux/micrel_phy.h                         |  1 +
>  3 files changed, 55 insertions(+), 2 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz8041.txt
>
> diff --git a/Documentation/devicetree/bindings/net/micrel-ksz8041.txt b/Documentation/devicetree/bindings/net/micrel-ksz8041.txt
> new file mode 100644
> index 0000000..4bce38d2
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/micrel-ksz8041.txt

    I think your text should be added to micrel.txt instead.

> @@ -0,0 +1,24 @@
> +Micrel KSZ8041 Gigabit Ethernet PHY
> +
> +The KSZ8041FTL variant supports fiber mode, enabled by the FXEN boot
> +strapping pin. It can't be determined from the PHY registers whether
> +the PHY is in fiber mode, so a boolean device tree property can be
> +used to describe this.
> +
> +Optional properties:
> + - fxen : KSZ8041FTL is strapped to fiber mode. Auto-negotiation is disabled

    It should be named micrel,fxen.

[...]

MBR, Sergei
