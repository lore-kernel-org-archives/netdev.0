From: Kyle Moffett <kyle@moffetthome.net>
Subject: Porting the ibm_newemac driver to use phylib (and other PHY/MAC
	questions)
Date: Fri, 17 Apr 2009 20:32:42 -0400
Message-ID: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:61747 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbZDRAco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 20:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm currently fiddling with a custom embedded prototype board using
the ibm_newemac driver with some currently-unsupported PHYs.  Those
PHYs *are* supported by phylib, but the emac driver seems to have its
own PHY layer cribbed from the sungem driver.  I'm curious if there's
some particular reason it hasn't been ported (aside from "nobody has
bothered yet").

I've temporarily hacked a PHY driver together for the moment, but it
would be much easier for us to maintain and update our board if the
PHY drivers were integrated.  As a result I'm also interested in how
complicated it might be to port the driver (and possibly sungem as
well) over to phylib, if that is indeed feasible.  Also, if I end up
going that route, are there others available with other hardware
variants who would be willing to test my patches on their boards?

As an aside, would there be any interest in adding an ethtool option
to enable the features of many PHYs which allow them to transmit data
even if their receive port has no link (specifically fiber cards, but
a few copper cards can do something similar).  From a cursory glance,
a third "duplex" configuration option would seem to make the most
sense from an end-user point of view.  Specifically, the existing
options are "full" (simultaneous transmit/receive), "half"
(time-multiplexed transmit/receive).  Perhaps a "tx" or "tx-only"
option would be sensible?  Now, the receiving card probably doesn't
need an "rx-only" mode as "full" should do that just fine; though
perhaps some cards with unidirectional-link-detection would use
"rx-only" to intentionally disable that support.  Once an extra couple
constants are added to linux/ethtool.h and the appropriate config
options added to ethtool, it should just be up to the drivers to
detect and handle those config options, no?

Comments and suggestions much appreciated.

Cheers,
Kyle Moffett
