From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/16] sfc: Add permissions to MCDI commands
Date: Mon, 18 May 2015 12:21:05 -0400 (EDT)
Message-ID: <20150518.122105.520335575641904166.davem@davemloft.net>
References: <555A044A.4060202@solarflare.com>
	<555A04C4.4080307@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbbERQVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 12:21:08 -0400
In-Reply-To: <555A04C4.4080307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Mon, 18 May 2015 16:27:00 +0100

> @@ -637,6 +637,9 @@
>   * Read multiple 32byte words from MC memory.
>   */
>  #define MC_CMD_READ32 0x1
> +#undef MC_CMD_0x1_PRIVILEGE_CTG
> +
> +#define MC_CMD_0x1_PRIVILEGE_CTG SRIOV_CTG_ADMIN

Please do not add unnecessary #undef statements like this.

It makes your code harder to read, and in particular harder to
audit for problems.  Because you're making it look like you are
explicitly overriding a definition from somewhere else, so people
have to go grepping around to find out where that is only to find
out that no such place even exists.
