From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] of: of_mdio: Add a whitelist of PHY
 compatibilities.
Date: Wed, 27 Jan 2016 16:51:38 +0300
Message-ID: <56A8CB6A.2070101@cogentembedded.com>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
 <1453853499-11248-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	aaro.koskinen@nokia.com, olof@lixom.net
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35202 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932385AbcA0Nvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 08:51:42 -0500
Received: by mail-lf0-f52.google.com with SMTP id c192so6356243lfe.2
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 05:51:41 -0800 (PST)
In-Reply-To: <1453853499-11248-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/27/2016 03:11 AM, Andrew Lunn wrote:

> Some phy nodes list a compatible value indicating the PHY make/model.
> This is never used to match the device to the driver. However it does
> confuse the code to separate a PHY from a generic MDIO device like a
> switch. Generic MDIO devices must have a compatible value, PHYs can
> list clause 22 or 45, but nothing else.
>
> Issue a warning if we find a compatible value known on the whitelist,

    My spell-checker trips on "whitelist"... Perhaps a space/hyphen needed?

> and say it is a PHY.
>
> Fixes: a9049e0c513c ("mdio: Add support for mdio drivers.")
> Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Reported-by: Olof Johansson <olof@lixom.net>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>   drivers/of/of_mdio.c | 27 +++++++++++++++++++++++++++
>   1 file changed, 27 insertions(+)
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index b5aa004a24b6..26c245041493 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -143,11 +143,31 @@ int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
>   }
>   EXPORT_SYMBOL(of_mdio_parse_addr);
>
> +/* The following is a list of PHY compatible strings which appear in
> + * some DTBs. The compatible string is never matched against a PHY
> + * driver, so is pointless. We only expect devices which are not PHYs
> + * to have a compatible string, so they can be matched to an MDIO
> + * driver.  Encourage users to upgrade there DT blobs to remove these.

    s/there/their/.

[...]
> @@ -166,6 +186,13 @@ static bool of_mdiobus_child_is_phy(struct device_node *child)
>   	if (of_device_is_compatible(child, "ethernet-phy-ieee802.3-c22"))
>   		return true;
>
> +	if (of_match_node(whitelist_phys, child)) {
> +		pr_warn(FW_WARN
> +			"%s: Whitelisted compatible string. Please remove\n",

    White-listed?

[...]

MBR, Sergei
