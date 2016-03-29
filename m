From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit on setup
Date: Tue, 29 Mar 2016 12:23:06 -0400
Message-ID: <87fuv9fe39.fsf@ketchup.mtl.sfl>
References: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org> <1459249908-4556-2-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, dennis@ausil.us, pbrobinson@gmail.com,
	Patrick Uiterwijk <patrick@puiterwijk.org>
To: Patrick Uiterwijk <patrick@puiterwijk.org>, linux@roeck-us.net,
	davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37975 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcC2QXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 12:23:09 -0400
In-Reply-To: <1459249908-4556-2-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

Two comments below.

Patrick Uiterwijk <patrick@puiterwijk.org> writes:

> +static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)

Since this function assumes the SMI lock is already held, its name
should be prefixed with _ by convention (_mv88e6xxx_power_on_serdes).

> +{
> +	int ret;
> +
> +	ret = _mv88e6xxx_phy_page_read(ds, REG_FIBER_SERDES, PAGE_FIBER_SERDES,
> +				       MII_BMCR);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (ret & BMCR_PDOWN) {
> +		ret = ret & ~BMCR_PDOWN;

                ret &= ~BMCR_PDOWN;

> +		ret = _mv88e6xxx_phy_page_write(ds, REG_FIBER_SERDES,
> +						PAGE_FIBER_SERDES, MII_BMCR,
> +						ret);
> +	}
> +
> +	return ret;
> +}

Thanks,
Vivien
