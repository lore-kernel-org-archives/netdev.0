From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 19/28] net: dsa: bcm_sf2: make it a real platform
 driver
Date: Wed, 23 Dec 2015 12:32:40 -0800
Message-ID: <567B04E8.5080900@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-20-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33940 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965352AbbLWUcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:32:43 -0500
Received: by mail-ob0-f181.google.com with SMTP id iw8so172078571obc.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:32:43 -0800 (PST)
In-Reply-To: <1450875402-20740-20-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> diff --git a/Documentation/devicetree/bindings/net/dsa/broadcom.txt b=
/Documentation/devicetree/bindings/net/dsa/broadcom.txt
> new file mode 100644
> index 000000000000..bd92be0ef2c8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/broadcom.txt
> @@ -0,0 +1,48 @@
> +* Broadcom Starfighter 2 integrated switch device
> +
> +Required properties:
> +
> +- compatible: should be "brcm,brcm-sf2"
> +- reg: addresses and length of the register sets for the device, mus=
t be 6
> +  pairs of register addresses and lengths
> +- interrupts: interrupts for the devices, must be two interrupts
> +
> +Optional properties:
> +
> +- reg-names: litteral names for the device base register addresses,
> +  when present must be: "core", "reg", "intrl2_0", "intrl2_1", "fcb"=
,
> +  "acb"

These are in fact mandatory properties.

> +
> +- interrupt-names: litternal names for the device interrupt lines,
> +  when present must be: "switch_0" and "switch_1"

Likewise

> +
> +- brcm,num-gphy: specify the maximum number of integrated gigabit PH=
Ys
> +  in the switch

Likewise

> +
> +- brcm,num-rgmii-ports: specify the maximum number of RGMII interfac=
es
> +  supported by the switch
> +
> +- brcm,fcb-pause-override: boolean property, if present indicates th=
at
> +  the switch supports Failover Control Block pause override capabili=
ty
> +
> +- brcm,acb-packets-inflight: boolean property, if present indicates
> +  that the switch Admission Control Block supports reporting the
> +  number of packets in-flight in a switch queue

All of these above are indeed optional.

Having to introduce a new binding for this driver to be converted is a
major deal breaker, the platforms I use have a frozen, yet wrongly
specified Device Tree binding, but still, we need to keep backward
compatibility with it.

My initial attempt, if you remove the part where I tried to convert
every switch driver into a PHY device handled that:

https://github.com/ffainelli/linux/commit/287fc1b33cdd6155c507a95531fd8=
20a5c6dbaf4

Since we have dsa_of_probe(), that alone should be enough to allow us t=
o
maintain a dsa_platform_data structure along with the old binding. This
is not a whole lot different from your patch 13.

Thanks!
--=20
=46lorian
