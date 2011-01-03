From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 03 Jan 2011 19:30:39 +0000
Message-ID: <1294083039.3167.184.camel@localhost>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
	 <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
	 <20110103.110244.183045594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12967 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab1ACTaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:30:46 -0500
In-Reply-To: <20110103.110244.183045594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-03 at 11:02 -0800, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 3 Jan 2011 10:47:20 -0800
> 
> > I'm not sure why this would be needed.  What is the a advantage in
> > making the TX and RX queues match?
> 
> That's how their hardware based RFS essentially works.
> 
> Instead of watching for "I/O system calls" like we do in software, the
> chip watches for which TX queue a flow ends up on and matches things
> up on the receive side with the same numbered RX queue to match.

ixgbe also implements IRQ affinity setting (or rather hinting) and TX
queue selection by CPU, the inverse of IRQ affinity setting.  Together
with the hardware/firmware Flow Director feature, this should indeed
result in hardware RFS.  (However, irqbalanced does not yet follow the
affinity hints AFAIK, so this requires some manual intervention.  Maybe
the OOT driver is different?)

The proposed change to make TX queue selection hash-based seems to be a
step backwards.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

