From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sh_eth: use RNC mode for R8A7790/R87791
Date: Mon, 02 Jun 2014 13:49:15 -0700 (PDT)
Message-ID: <20140602.134915.1162774321657125992.davem@davemloft.net>
References: <1401729456-23514-1-git-send-email-ben.dooks@codethink.co.uk>
	<20140602.115303.1283021229124256917.davem@davemloft.net>
	<538CD19B.5060208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@codethink.co.uk,
	netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au,
	yoshihiro.shimoda.uh@renesas.com, cm-hiep@jinso.co.jp
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196AbaFBUtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 16:49:16 -0400
In-Reply-To: <538CD19B.5060208@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 02 Jun 2014 23:33:47 +0400

>    Looks like the early SH2/3 SoCs didn't implement the whole register.
> Despite that, sh_eth_dev_init() always writes to this register... :-/
> So far, the RMCR.RNC bit was mostly set for the Gigabit-capable
> controllers, however that rule wasn't strictly followed. Well, this
> driver is still a mess, and it's hard to deal with it without the
> necessary documentation.

Why don't we therefore:

1) Skip the register write if the per-chip value is zero.

2) Add the RNC bit to all of the gigabit capable controllers.
