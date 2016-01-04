From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next 05/24] phy: add phydev_name() macro
Date: Mon, 04 Jan 2016 09:48:47 -0800
Message-ID: <1451929727.4334.100.camel@perches.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
	 <1451929022-5580-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0002.hostedemail.com ([216.40.44.2]:42721 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752025AbcADRsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 12:48:50 -0500
In-Reply-To: <1451929022-5580-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-04 at 18:36 +0100, Andrew Lunn wrote:
> Add a phydev_name() macro, to help with moving some structure members
> from phy_device.
[]
> diff --git a/include/linux/phy.h b/include/linux/phy.h
[]
> @@ -783,6 +783,8 @@static inline int phy_read_status(struct phy_devic=
e *phydev)
> =A0#define phydev_dbg(_phydev, format, args...)	\
> =A0	dev_dbg(&_phydev->dev, format, ##args)
> =A0
> +#define phydev_name(_phydev) dev_name(&_phydev->dev)
> +

This should use parentheses around phydev

#define phydev_name(phydev)	dev_name(&(phydev)->dev)

or likely even better be a static inline

static inline const char * phydev_name(const struct phy_device *phydev)
{
	return dev_name(&phydev->dev);
}
