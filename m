From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Fri, 11 Jul 2014 15:01:36 -0700 (PDT)
Message-ID: <20140711.150136.1090869144440145481.davem@davemloft.net>
References: <1405074434-13947-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
	sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbaGKWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 18:01:37 -0400
In-Reply-To: <1405074434-13947-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Fri, 11 Jul 2014 18:27:14 +0800

> +	if (i < budget) {
> +		napi_complete(napi);
> +		if (!(bfin_read_IPEND() & IRQ_EVX))
> +			enable_irq(IRQ_MAC_RX);
> +	}

This doesn't make any sense, why are you only re-enabling the
interrupt if the status bit is clear?

You should do this unconditionally.

If your logic triggers, polling is disabled and the interrupt handler
isn't going to run, so your driver will stop taking packets.

Please please, stop being so clever with the conditions here, simply
if you didn't use the whole budget turn off NAPI and reenable
interrupts.
