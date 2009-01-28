From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
 hashing.
Date: Wed, 28 Jan 2009 10:50:58 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1C225B4C@orsmsx507.amr.corp.intel.com>
References: <20090127.164027.245779962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55999 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbZA1SvA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 13:51:00 -0500
In-Reply-To: <20090127.164027.245779962.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> The idea is that drivers which implement multiqueue RX
> pre-seed the SKB by recording the RX queue selected by
> the hardware.
> 
> If such a seed is found on TX, we'll use that to select
> the outgoing TX queue.
> 
> This helps get more consistent load balancing on router
> and firewall loads.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/skbuff.h |   15 +++++++++++++++
>  net/core/dev.c         |    8 ++++++++
>  2 files changed, 23 insertions(+), 0 deletions(-)

Hi Dave, thanks for doing this work, it looks very interesting, I'm curious 
what you think should happen with the tx / rx interrupts when every queue has 
a unique interrupt number.

I don't think the irqbalance daemon is smart enough to know that a given
tx queue should always end up either cache coherent (different core) or
core-coherent (same core) to the rx queue.

So, is it still expected that users running routing setups will always
have to hand-tune /proc/irq/NNN/smp_affinity for each of the tx and rx
queues?

Ideally the routing case would somehow end up working like the socket case
where the scheduler would notice the wakeups cross cpu and move the interrupt
for the routing case in the same way (I assume from your previous comments) it
would move the interrupt for a socket based application.

I hope to be able to test this today or tomorrow.