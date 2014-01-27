From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] DT: net: davinci_emac: "ti,davinci-rmii-en" property
 is actually optional
Date: Mon, 27 Jan 2014 14:57:14 -0800
Message-ID: <CAGVrzcYdd3KjoHyAS2_y5e9BBPk4O9t7pCiCqoWGXQ=T6Qg-yA@mail.gmail.com>
References: <201401280247.42415.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	davinci-linux-open-source@linux.davincidsp.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:65408 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbaA0W5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 17:57:54 -0500
In-Reply-To: <201401280247.42415.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-27 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Though described as required, the "ti,davinci-rmii-en" property for the DaVinci
> EMAC binding seems actually optional, as the driver should happily work without
> it; the property is not specified either  in the example device node or in the
> actual EMAC device node for DA850 device tree, only AM3517 one.
>
> While at it, document the property better...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
> Actually I think this property should have been boolean...
>
>  Documentation/devicetree/bindings/net/davinci_emac.txt |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: net/Documentation/devicetree/bindings/net/davinci_emac.txt
> ===================================================================
> --- net.orig/Documentation/devicetree/bindings/net/davinci_emac.txt
> +++ net/Documentation/devicetree/bindings/net/davinci_emac.txt
> @@ -10,7 +10,6 @@ Required properties:
>  - ti,davinci-ctrl-mod-reg-offset: offset to control module register
>  - ti,davinci-ctrl-ram-offset: offset to control module ram
>  - ti,davinci-ctrl-ram-size: size of control module ram
> -- ti,davinci-rmii-en: use RMII
>  - ti,davinci-no-bd-ram: has the emac controller BD RAM
>  - interrupts: interrupt mapping for the davinci emac interrupts sources:
>                4 sources: <Receive Threshold Interrupt
> @@ -22,6 +21,7 @@ Optional properties:
>  - phy-handle: Contains a phandle to an Ethernet PHY.
>                If absent, davinci_emac driver defaults to 100/FULL.
>  - local-mac-address : 6 bytes, mac address
> +- ti,davinci-rmii-en: 1 byte, 1 means use RMII

This just made me look at the actual DT binding documentation and the
driver, but there is support for specifying a PHY device tree node,
but no corresponding 'phy-connection-type' property which would tell
whether the connection is Reduced MII, MII or something else.
'phy-connection-type' would convey much more information about what is
happening, and once know, should also make the driver automatically
configure for Reduced MII or anything else, hence making
"ti,davinc-rmii-en" obsolete.
-- 
Florian
