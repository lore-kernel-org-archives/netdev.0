From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 12/24] of: phy: Only register a phy device
 for phys
Date: Mon, 04 Jan 2016 12:01:04 -0800
Message-ID: <568ACF80.5070105@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-13-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35889 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbcADUBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:01:38 -0500
Received: by mail-pf0-f195.google.com with SMTP id q63so18471206pfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:01:37 -0800 (PST)
In-Reply-To: <1451929022-5580-13-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> We will soon support devices other than phys on the mdio bus. Look at
> a child's compatibility string to determine if it is a phy, before
> registering a phy device.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---

[snip]

> +	if (of_get_phy_id(child, &phy_id) != -EINVAL)
> +		return true;
> +
> +	if (of_device_is_compatible(child, "ethernet-phy-ieee802.3-c45"))
> +		return true;

Is there a particular reason not to check for
"ethernet-phy-ieee802.3-c22 here?

> +
> +	if (!of_find_property(child, "compatible", NULL))
> +		return true;

That seems reasonable, we should probably make the compatible string for
PHY Device Tree nodes not an optional property anymore though, but
that's for a separate change and topic.
-- 
Florian
