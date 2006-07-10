From: David Miller <davem@davemloft.net>
Subject: Re: active-backup/bonding with drivers not supporting
 set_mac_address()
Date: Mon, 10 Jul 2006 11:45:30 -0700 (PDT)
Message-ID: <20060710.114530.125253070.davem@davemloft.net>
References: <Pine.LNX.4.64.0607101618390.26558@zuben>
	<200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@voltaire.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49104
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422773AbWGJSov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:44:51 -0400
To: fubar@us.ibm.com
In-Reply-To: <200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 10 Jul 2006 11:29:14 -0700

> 	What network device drivers are there that don't permit ever
> changing the device MAC address?

Good question.

Look at a driver such as 3c509.c, for example.

Sure, it will get the default eth_mac_addr() software implementation,
but this is not going to do what you expect.

It may change the dev->dev_addr[] value, and change the MAC address
used on outgoing packets, but it is unlikely to make the device
actually receive packets with the MAC address in non-promiscuous
mode.

If the driver isn't setting up an explicit ->set_mac_address handler,
it isn't going to be programming the RX MAC of the chip and therefore
not recognize packets to that new MAC as destined for it.

