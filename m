From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] sfc:On MCDI timeout, issue an FLR (and mark
 MCDI to fail-fast)
Date: Wed, 16 Apr 2014 14:35:03 -0400 (EDT)
Message-ID: <20140416.143503.820604109876720374.davem@davemloft.net>
References: <534ECBA4.20408@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	rstonehouse@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbaDPSfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 14:35:07 -0400
In-Reply-To: <534ECBA4.20408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 16 Apr 2014 19:27:48 +0100

> From: Edward Cree <ecree@solarflare.com>
> 
> When an MCDI command times out (whether or not we find it
> completed when we poll), call efx_mcdi_abandon(), which tells
> all subsequent MCDI calls to fail-fast, and queues up an FLR.
> 
> Because an FLR doesn't lead to receiving any reboot even from
> the MC (unlike most other types of reset), we have to call
> efx_ef10_reset_mc_allocations.
> In efx_start_all(), if a reset (of any kind) is pending, we
> bail out.
> Without this, attempts to reconfigure (e.g. change mtu) can
> cause driver/mc state inconsistency if the first MCDI call
> triggers an FLR.
> 
> For similar reasons, on EF10, in
> efx_reset_down(method=RESET_TYPE_MCDI_TIMEOUT), set the number
> of active queues to zero before calling efx_stop_all().
> And, on farch, in efx_reset_up(method=RESET_TYPE_MCDI_TIMEOUT),
> set active_queues and flushes pending & outstanding to zero.
> 
> efx_mcdi_mode_{poll,event}() should not take us out of fail-fast
>  mode. Instead, this is done by efx_mcdi_reset() after the FLR
> completes.
> 
> The new FLR reset_type RESET_TYPE_MCDI_TIMEOUT doesn't really
> fit into the hierarchy of reset 'scopes' whereby efx_reset()
> decides some resets subsume others.  Thus, it uses separate logic.
> 
> Also, fixed up some inconsistency around RESET_TYPE_MC_BIST,
> which was in the wrong place in that hierarchy.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
