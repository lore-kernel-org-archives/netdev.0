From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Thu, 10 Jul 2014 16:53:42 -0700 (PDT)
Message-ID: <20140710.165342.434372844542249917.davem@davemloft.net>
References: <1404985944-30463-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
	sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbaGJXxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 19:53:45 -0400
In-Reply-To: <1404985944-30463-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Thu, 10 Jul 2014 17:52:24 +0800

> +	if (i < budget && !test_bit(NAPI_STATE_NPSVC, &napi->state)) {
> +		napi_complete(napi);
> +		enable_irq(IRQ_MAC_RX);
> +	}

Drivers are not supposed to test this bit directly.

If you have not exhausted the budget, and the chip has no more work to
do, you should unconditionally exit the NAPI poll.
