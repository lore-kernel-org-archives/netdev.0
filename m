From: "Kyle Moffett" <kyle@moffetthome.net>
Subject: [RFC] Best method to control a "transmit-only" mode on fiber NICs (specifically sky2)
Date: Fri, 15 Feb 2008 22:41:46 -0500
Message-ID: <f73f7ab80802151941x5daf34e3scd0f42a05291db51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Linux NetDev" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:14944 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552AbYBPDls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 22:41:48 -0500
Received: by py-out-1112.google.com with SMTP id u52so1133868pyb.10
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 19:41:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The company I'm working for has an unusual fiber NIC configuration
that we use for one of our network appliances.  We connect only a
single fiber from the TX port on one NIC to the RX port on another
NIC, providing a physically-one-way path for enhanced security.
Unfortunately this doesn't work with most NIC drivers, as even with
auto-negotiation off they look for link probe pulses before they
consider the link "up" and are willing to send packets.  We have been
able to use Myricom 10GigE NICs with a custom firmware image.  More
recently we have patched the sky2 driver to turn on the FIB_FORCE_LNK
flag in the PHY control register; this seems to work on the
Marvell-chipset boards we have here.

What would be the preferred way to control this "force link" flag?
Right now we are accessing it using ethtool; we have added an
additional "duplex" mode: "DUPLEX_TXONLY", with a value of 2.  When
you specify a speed and turn off autonegotiation ("./patched-ethtool
-s eth2 speed 1000 autoneg off duplex txonly"), it will turn on the
specified bit in the PHY control register and the link will
automatically come up.  We also have one related bug-fix^Wdirty hack
for sky2 to reset the PHY a second time during netif-up after enabling
interrupts; otherwise the immediate "link up" interrupt gets lost.
Once I get approval from the company I will patch the post itself for
review.

I look forward to your comments and suggestions

Cheers,
Kyle Moffett
