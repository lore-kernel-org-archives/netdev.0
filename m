From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:33:02 -0700 (PDT)
Message-ID: <20060928.153302.48822033.davem@davemloft.net>
References: <1159474625.3741.6.camel@rh4>
	<20060928.151358.01288837.davem@davemloft.net>
	<451C4BD6.7050200@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9091
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161343AbWI1Wc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:32:59 -0400
To: jgarzik@pobox.com
In-Reply-To: <451C4BD6.7050200@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 28 Sep 2006 18:25:26 -0400

> GWOL now spits out a password for all users -> security risk.  Ditto 
> GEEPROM.  GSET has been known to cause hangs if done in a tight loop, on 
> some 10/100 cards, which is now permitted by any user.  At the very 
> least, it should be rate-limited.
> 
> I wasn't just being obstinate, when requesting an audit.

Ok, I've removed GSET, GWOL and GSTATS (GEEPROM was not in the
original list in Stephen's patch).  In fact I'll remove
GLINK too as that might touch the hardware as well.

That leaves us with:

	case ETHTOOL_GDRVINFO:
	case ETHTOOL_GMSGLVL:
	case ETHTOOL_GCOALESCE:
	case ETHTOOL_GRINGPARAM:
	case ETHTOOL_GPAUSEPARAM:
	case ETHTOOL_GRXCSUM:
	case ETHTOOL_GTXCSUM:
	case ETHTOOL_GSG:
	case ETHTOOL_GSTRINGS:
	case ETHTOOL_GTSO:
	case ETHTOOL_GPERMADDR:
	case ETHTOOL_GUFO:
	case ETHTOOL_GGSO:

Which should be ok.

And once again, take even this list with a grain of salt, we
have until 2.6.19-final to sort this out and audit things.
