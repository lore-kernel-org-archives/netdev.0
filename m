From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] alx: fix alx_poll()
Date: Sun, 11 Jan 2015 21:46:36 -0500 (EST)
Message-ID: <20150111.214636.57922661070968241.davem@davemloft.net>
References: <54B199EB.1080004@amd.com>
	<1420926614.5947.89.camel@edumazet-glaptop2.roam.corp.google.com>
	<1421001138.5947.100.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oded.gabbay@amd.com, johannes.berg@intel.com, edumazet@google.com,
	netdev@vger.kernel.org, willemb@google.com, John.Bridgman@amd.com,
	Dana.Elifaz@amd.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbbALCqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 21:46:38 -0500
In-Reply-To: <1421001138.5947.100.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 11 Jan 2015 10:32:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit d75b1ade567f ("net: less interrupt masking in NAPI") uncovered
> wrong alx_poll() behavior.
> 
> A NAPI poll() handler is supposed to return exactly the budget when/if
> napi_complete() has not been called.
> 
> It is also supposed to return number of frames that were received, so
> that netdev_budget can have a meaning.
> 
> Also, in case of TX pressure, we still have to dequeue received
> packets : alx_clean_rx_irq() has to be called even if
> alx_clean_tx_irq(alx) returns false, otherwise device is half duplex.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: d75b1ade567f ("net: less interrupt masking in NAPI")
> Reported-by: Oded Gabbay <oded.gabbay@amd.com>
> Bisected-by: Oded Gabbay <oded.gabbay@amd.com>
> Tested-by: Oded Gabbay <oded.gabbay@amd.com>

Applied and queued up for -stable, thanks Eric.
