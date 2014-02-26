From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sfc: check for NULL efx->ptp_data in
 efx_ptp_event
Date: Wed, 26 Feb 2014 15:22:44 -0500 (EST)
Message-ID: <20140226.152244.2248312700324231740.davem@davemloft.net>
References: <alpine.LFD.2.03.1402251306530.16190@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sshah@solarflare.com, ben@decadent.org.uk
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbaBZUWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:22:46 -0500
In-Reply-To: <alpine.LFD.2.03.1402251306530.16190@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 25 Feb 2014 13:17:59 +0000

> If we receive a PTP event from the NIC when we haven't set up PTP state
> in the driver, we attempt to read through a NULL pointer efx->ptp_data,
> triggering a panic.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> v2: resent using alpine, because Thunderbird mangled v1
> 
> While this shouldn't happen with existing released firmware, future
> sfn7322f firmware is planned to enable PPS irrespective of whether
> timestamping (and thus PTP) is enabled.  We are considering workarounds,
> but this defensive patch seemed like a good idea anyway in case the
> firmware gets in a muddle.
> Also, in principle this shouldn't happen on 3.14+ kernels as the driver
> should always set up PTP state at probe time (though there might still
> be a race against the firmware sending its first PPS), however 3.12 and
> 3.13 both supported EF10 but not PTP-on-EF10 and thus they never set up
> the PTP state; hence this fix should also be backported to those series.

Applied and queued up for -stable, thanks.
