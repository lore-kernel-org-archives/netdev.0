From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next 00/15] drivers/net: obsolete ISA driver round-up
Date: Tue, 22 Jan 2013 09:46:53 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B711C@saturn3.aculab.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Donald Becker" <becker@scyld.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Alan Cox" <alan@linux.intel.com>, "Andreas Mohr" <andi@lisas.de>,
	"Jan-Pascal van Best" <janpascal@vanbest.org>,
	"Mika Kuoppala" <miku@iki.fi>
To: "Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50242 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752044Ab3AVJtC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 04:49:02 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16684-03 for <netdev@vger.kernel.org>;
 Tue, 22 Jan 2013 09:48:58 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICL did ship a lot of 8bit ISA ethernet cards with the intel
chipset (might have been sourced from a 3rd party) - clearly
the hardware engineers built the cards without asking the
software guys about which chips were easy to drive.
The amd lance chips were easy (even allowing for some
little errata [1]), the intel one a real PITA.
Fortunately I never had to fix the Intel driver, largely
because I was doing the drivers for sparc systems.

But yes, on a 386/486 none of the PIO based 8-bit ethernet
cards could get anywhere near saturating a 10M LAN.
(Well, maybe just, and with full sized packets.)
Put the cards in a PCI system and it is actually worse.
Not only that, but while doing the slow ISA io the
cpu is spinning - so you really, really wanted a PCI
ethernet card.

So the only systems where you would be running an ISA
ethernet card are old 486 ones (not to be confused
with some new embedded 486 cpu).

So even the later ISA-pnp cards are of limited use.

Trying to use something based on the amd pcnet-isa
(lance on a card) is also fraught - as you need to
get one of the motherboard dma channels into
'cascade mode' - often not supported by the OS.
(And you'll probably fail to run the bloated board
EEPROM config tool as well.)

All best dead and buried!

	David

[1] It really didn't like bus cycles terminating anywhere
near the 256 clocks cycle timeout.
