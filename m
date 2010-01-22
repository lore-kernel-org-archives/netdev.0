From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Thu, 21 Jan 2010 22:25:01 -0800
Message-ID: <1264141501.32383.75.camel@Joe-Laptop.home>
References: <4B593B74.2020601@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	chavey@google.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1418 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab0AVGZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jan 2010 01:25:06 -0500
In-Reply-To: <4B593B74.2020601@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial:

All of the printks without KERN_<level> should be KERN_CONT

For example:

> +	printk(KERN_ERR "%-15s ", rname);
> +	for (n = 0; n < 2; n++)
> +		printk("%08x ", __er32(hw, get_regofs(n)));
> +	printk("\n");

This should be:

	printk(KERN_ERR etc...)
	for (n = 0...)
		printk(KERN_CONT "%08x ", etc...
	printk(KERN_CONT "\n")

or perhaps written without the for loop

	printk(KERN_ERR "%-15s %08x %08x\n",
	       name, __er32(hw, get_regofs(0)), __er32(hw, get_regofs(1)));

