From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:15:29 -0700 (PDT)
Message-ID: <20060928.151529.25156954.davem@davemloft.net>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
	<451C2F52.6040003@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5078
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932528AbWI1WP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:15:26 -0400
To: jgarzik@pobox.com
In-Reply-To: <451C2F52.6040003@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 28 Sep 2006 16:23:46 -0400

> NAK.
> 
> Some functions in the past didn't like getting hit rapidly in succession.
> 
> I would agree to this, but only after an exhaustive audit of each driver 
> and each sub-ioctl.  Right now, I only have confidence in GDRVINFO 
> probably being safe -- but still that requires an audit, since in rare 
> cases the driver may be poking firmware and eeprom areas.

I think the purely software state ones are safe, such as GDRVINGO,
GSG, GTSO, etc.  This absolutely excludes things like PHYS_ID
and GREGS which almost always have to touch the hardware.

> Finally, I fixed a buffer overflow in ethtool version 5, so an audit to 
> make sure overflows cannot affect the kernel is basically _required_.

Absolutely.

I think we should put in Stephen's change with the obvious PHYS_ID
and GREGS exceptions removed.  We have a lot of time to make sure
everything remaining is kosher for 2.6.19 ok?
