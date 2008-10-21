From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Tue, 21 Oct 2008 16:26:56 -0700 (PDT)
Message-ID: <20081021.162656.265919635.davem@davemloft.net>
References: <20081021061851.GA6293@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58442
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751957AbYJUX1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 19:27:19 -0400
In-Reply-To: <20081021061851.GA6293@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 21 Oct 2008 02:18:51 -0400

> BIG FAT WARNING:  This requires upstream's PCIE_LINK_STATE_L0S from
> include/linux/pci-aspm.h in order to build properly.  It should build
> if you pull the latest Linus tree into net-2.6, to update net-2.6.

I did the pull from Linus's tree, but the problem is that nothing in
the IGB driver seems to bring that pci-aspm.h include file in.

Thus it doesn't build:

drivers/net/igb/igb_main.c: In function 'igb_probe':
drivers/net/igb/igb_main.c:1018: error: 'PCIE_LINK_STATE_L0S' undeclared (first use in this function)
drivers/net/igb/igb_main.c:1018: error: (Each undeclared identifier is reported only once
drivers/net/igb/igb_main.c:1018: error: for each function it appears in.)
make[3]: *** [drivers/net/igb/igb_main.o] Error 1
make[2]: *** [drivers/net/igb] Error 2
make[2]: *** Waiting for unfinished jobs....

So, I can't see how it builds successfully on any platform :-)

Doing a "git grep pci-aspm.h" shows just a few *.c files under drivers/pci
and nothing else.

Please fix this up.

