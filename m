From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: spidernet: dynamic phy setup code
Date: Mon, 05 Feb 2007 11:08:07 +1100
Message-ID: <1170634087.2620.69.camel@localhost.localdomain>
References: <200702021020.l12AKLrS011304@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	jim@jklewis.com, netdev@vger.kernel.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41453 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbXBEAIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Feb 2007 19:08:40 -0500
In-Reply-To: <200702021020.l12AKLrS011304@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We use bcm5461. There is a possibility that we don't know the appropriate
> setting which is applicable for both type of switches.

Have you tested the existing 54xx code in sungem_phy.c ? We use that
with 5462 at least in K2 and all sorts of 54xx chips and it works
fine... Just setup the right advertisement bits and call setup_aneg in
the PHY ops. You don't even need to implement the "forced" fallback code
that is in sungem. It's not necessary with most broadcom PHYs as they do
that themselves, just setup aneg and poll the link from a timer, that's
it. Once you get a link, then setup your GMACMODE based on the link
speed.

I don't have the datasheet of the 5461 at hand but I doubt it's any
different... Like other Broadcom 54xx PHYs, it might need some special
initialization code to work around firmware bugs though...

> We didn't investigate for the detail, but we met the following phenomena.
> 1. When auto-neg starts with Gbps setting and ethernet card is connected to
>    a 100Mbps switch, LINK is not detected.
> 2. When auto-neg starts with 100/10Mbps setting and ethernet card is 
>    connected to Gbps switch, LINK is detected (poll_link() succeeds), but
>    the network is not available.

That is very strange... I would need to review your code in more details
or eventually have HW access to run my own experiments, but none of this
should happen if things are setup properly. Also avoid relying on the
link interrupt, it's a known cause of trouble. Just poll.

Ben.


