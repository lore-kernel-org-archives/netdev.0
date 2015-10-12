From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sfc: replace spinlocks with bit ops for
 busy poll locking
Date: Mon, 12 Oct 2015 05:31:39 -0700 (PDT)
Message-ID: <20151012.053139.813936137450671826.davem@davemloft.net>
References: <56178680.9020702@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbJLMPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:15:51 -0400
In-Reply-To: <56178680.9020702@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 9 Oct 2015 10:18:56 +0100

>  static void efx_remove_port(struct efx_nic *efx);
> -static void efx_init_napi_channel(struct efx_channel *channel);
> +static int efx_init_napi_channel(struct efx_channel *channel);

The changes to modify the call chain to return a status code is
completely unnecessary, and distracts from the core of what this
patch is actually doing.

Nothing signals an error, all of these code paths return '0',
so it's pointless to return a status or check such statuses.
