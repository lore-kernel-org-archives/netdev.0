From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 00/13] dmaengine redux
Date: Fri, 12 Dec 2008 14:27:57 +0000
Message-ID: <129600E5E5FB004392DDC3FB599660D70C8F3402@irsmsx504.ger.corp.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36411 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758469AbYLLO2N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 09:28:13 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Dan J wrote:
> The dmaengine subsystem collects and advertises dma channels for two
> classes of users in the kernel, memory-to-memory offload and
> traditional device-to-memory DMA.  The original design was driven by
> the memory-to-memory case and is starting to show its limitations now
> that more device-to-memory DMA users are being planned.  The primary
> difference between the two classes is that memory-to-memory offload
> is very amenable to channel sharing and is tolerant of dynamic
> channel changes.  Compare this to the device-to-memory case where a
> channel must be dedicated to a device and may have platform-specific
> reasons why it cannot talk to a different device. 
> 
> This rework allows channels to be targeted to a public (mem-to-mem)
> pool or be reserved for an exclusive private (dev-to-mem) allocation.
> See [PATCH 1/13] for documentation of the changes.  A nice side
> effect of the rework is: 
> 
>  24 files changed, 679 insertions(+), 1108 deletions(-)
> 
> All review welcomed, especially around the dma_slave changes, or
> performance impacts of dma_find_channel.
> 
> These patches are currently on async_tx.git/upstream, and barring any
> brown-paper-bag issues will move to linux-next via async_tx.git/next.
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/djbw/async_tx.git
> upstream 
> 
> ---
> Dan Williams (13):
>       dmaengine: kill enum dma_state_client
>       dmaengine: remove 'bigref' infrastructure
>       dmaengine: kill struct dma_client and supporting infrastructure
>       dmaengine: replace dma_async_client_register with dmaengine_get
>       atmel-mci: convert to dma_request_channel and down-level
>       dma_slave dmatest: convert to dma_request_channel
>       dmaengine: introduce dma_request_channel and private channels
>       net_dma: convert to dma_find_channel
>       dmaengine: provide a common 'issue_pending_all' implementation
>       dmaengine: centralize channel allocation, introduce
>       dma_find_channel dmaengine: up-level reference counting to the
>       module level dmaengine: remove dependency on async_tx
>       async_tx, dmaengine: document channel allocation and api rework
> 
>  Documentation/crypto/async-tx-api.txt |  135 +++----
>  Documentation/dmaengine.txt           |    1
>  arch/avr32/include/asm/atmel-mci.h    |    6
>  arch/avr32/mach-at32ap/at32ap700x.c   |   15 -
>  crypto/async_tx/async_tx.c            |  350 ------------------
>  drivers/dma/Kconfig                   |    2
>  drivers/dma/dmaengine.c               |  637
>  +++++++++++++++++++++++---------- drivers/dma/dmatest.c             
>  |  111 ++---- drivers/dma/dw_dmac.c                 |   28 -
>  drivers/dma/fsldma.c                  |    3
>  drivers/dma/ioat_dma.c                |    5
>  drivers/dma/iop-adma.c                |   11 -
>  drivers/dma/mv_xor.c                  |   11 -
>  drivers/mmc/host/atmel-mci.c          |  103 +----
>  include/linux/async_tx.h              |   17 -
>  include/linux/dmaengine.h             |  148 ++------
>  include/linux/dw_dmac.h               |   31 +-
>  include/linux/netdevice.h             |    3
>  include/net/netdma.h                  |   11 -
>  net/core/dev.c                        |  148 --------
>  net/ipv4/tcp.c                        |    5
>  net/ipv4/tcp_input.c                  |    2
>  net/ipv4/tcp_ipv4.c                   |    2
>  net/ipv6/tcp_ipv6.c                   |    2
>  24 files changed, 679 insertions(+), 1108 deletions(-)
>  create mode 100644 Documentation/dmaengine.txt

Dan,

First of all sorry for delay in my feedback on this.
I have been absent for couple of weeks and last days
I was struggling with some ioatdma hot issues.

I have walked through these patches and generally
I like the whole redesign/reduction idea.
There are couple of concerns/questions (+ minor comments) from my side
to three of these patches: 3, 7 and 11.
I will send them in a minute.
The rest of them looks good to me at this point.

Next week I am planning to run some tests on my I/OAT setup,
to see how this new dmaengine would behave in this environment.
I will let you know.

Regards,
Maciej