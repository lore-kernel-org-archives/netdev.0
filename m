From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl_pq_mdio: use spin_event_timeout() to poll the
 indicator register
Date: Sun, 08 Jul 2012 23:59:26 -0700 (PDT)
Message-ID: <20120708.235926.1117975937932919247.davem@davemloft.net>
References: <1341357381-10861-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab2GIG71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 02:59:27 -0400
In-Reply-To: <1341357381-10861-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Tue, 3 Jul 2012 18:16:21 -0500

> Macro spin_event_timeout() was designed for simple polling of hardware
> registers with a timeout, so use it when we poll the MIIMIND register.
> This allows us to return an error code instead of polling indefinitely.
> 
> Note that PHY_INIT_TIMEOUT is a count of loop iterations, so we can't use
> it for spin_event_timeout(), which asks for microseconds.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Define a macro for the timeout value rather than use an arbitrary
constant.

> +	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
> +		1000, 0);

This indentation is absolutely terrible.

> +	status = spin_event_timeout(!(in_be32(&regs->miimind) &
> +		(MIIMIND_NOTVALID | MIIMIND_BUSY)), 1000, 0);

Same here.

> +	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
> +		1000, 0);

And here too.
