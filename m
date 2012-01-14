From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of
 failing probe
Date: Sat, 14 Jan 2012 00:14:30 -0800 (PST)
Message-ID: <20120114.001430.787918662083526597.davem@davemloft.net>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: dvhart@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663Ab2ANIOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 03:14:41 -0500
In-Reply-To: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Darren Hart <dvhart@linux.intel.com>
Date: Fri, 13 Jan 2012 22:44:55 -0800

> If the MAC is invalid or not implemented, use a randomly generated one rather
> than failing the probe. Store the generated addr in a new sw_mac array in the
> pch_gbe_mac_info structure. Take care to allow for assigning the MAC via
> ifconfig by reusing sw_addr to store an assigned mac if probe populated it with
> a random one (otherwise the assignment would rely on the ROM and the reset would
> fail to write a valid MAC to the rx filter).
> 
> Tested on two platforms, one with a valid MAC, the other without a MAC. The
> real MAC is used if present, a randomly generated one otherwise. Both are
> capable of changing the MAC with ifconfig. They successfully get an IP over
> DHCP and pass a simple ping and login over ssh test.
> 
> This does not make any attempt to address a missing or invalid MAC for the
> pch_phub driver.
> 
> Signed-off-by: Darren Hart <dvhart@linux.intel.com>

I don't want to see code like this added if it's "just in case."

Please correct any hardware that hasn't shipped yet or is alpha/beta
hardware in testing, so that we don't need stuff like this.
