From: David Miller <davem@davemloft.net>
Subject: Re: softmac mtu
Date: Sat, 23 Sep 2006 15:23:38 -0700 (PDT)
Message-ID: <20060923.152338.74560339.davem@davemloft.net>
References: <4515A9BF.90709@lwfinger.net>
	<20060923.144757.78710420.davem@davemloft.net>
	<4515AE54.4040403@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: castet.matthieu@free.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30649
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750718AbWIWWXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 18:23:39 -0400
To: Larry.Finger@lwfinger.net
In-Reply-To: <4515AE54.4040403@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Sat, 23 Sep 2006 16:59:48 -0500

> Where/how does the device allow it? When I tried 'ifconfig eth0 mtu
> 2000' on my VIA Technologies, Inc. VT6102 [Rhine-II] wired
> controller, I got a 'SIOCSIFMTU: Invalid argument' message, which is
> the same message I get on my BCM4306 wireless card.

It allows it in the device specific ->change_mtu() method.
Tigon3, for example, overrides this with it's own function
called tg3_change_mtu() which checks if the particular model
of the chip supports jumbo MTU and if so allows such a setting.

The VIA driver simply doesn't override that function, and uses
the default ethernet one because either that ethernet chip doesn't
support the larger MTU or the author simply hasn't gotten around
to implementing the override.
