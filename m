From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 0/4] crypto/chcr: Add support for Chelsio Crypto Driver
Date: Wed, 17 Aug 2016 12:33:02 +0530
Message-ID: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	atul.gupta@chelsio.com, yeshaswi@chelsio.com, jlulla@chelsio.com,
	harsh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

This patch series adds support for Chelsio Crypto driver. 

The patch series has been created against net-next tree and includes
patches for Chelsio Low Level Driver(cxgb4) and adds the new crypto
Upper Layer Driver(chcr) under a new directory drivers/crypto/chelsio.

Patch 1/4 ("cxgb4: Add support for dynamic allocation of resources for
ULD") adds support for dynamic allocation of resources for ULD. The
objective of this patch is to provide generic interface for upper layer
drivers to allocate and initialize hardware resources.

The present cxgb4 (network driver) apart from network functionality, also
initializes hardware and thus acts as lower layer driver for other drivers
to use hardware resources. Thus it acts as both a Low level driver for
Upper layer driver's like iw_cxgb4, cxgb4i and cxgb4it and a Network Driver.

Right now the allocation of resources for Upper layer driver's is done
statically. Patch 1/4 adds a new infrastructure for dynamic allocation of
resources. cxgb4 will read the hardware capability through firmware and
allocate/free the queues for Upper layer drivers when the respective
driver's are loaded and freed when unloaded.

Patch 2/3, 3/4 and 4/4 adds support for Chelsio Crypto Driver. The Crypto
driver will act as another ULD on top of cxgb4.

In this patch series, the ULD API framework is used only by crypto and other
ULD's will make use of it in the next series. 

This patch series is only for review, if this looks ok we will test it
thoroughly and send request for merge. 

We have included all the maintainers of respective drivers. Kindly
review the changes and provide feedback on the same.

V3: - Removed crypto queues from cxgb4 and added support for dynamic
      allocation of resources for Upper layer drivers
    - Dependency fix in Kconfig.

V2: - Some residual code cleanup
    - Adds pr_fmt with chcr (KBUILD_MODNAME) added
    - Changes var name to accomodate them <80 columns in the chcr_register_alg
    - Support for printing the crypto queue stats
    - Fix compile warnings reported by kbuild bot for certain architectures
    - Dependency fix in Kconfig.
    - If the request has the MAY_BACKLOG bit set and hardware queue is
      full the request is queued up else -EBUSY is returned to throttle
      the user. The queue when executed and processed returns -EINPROGRESS
      in completion.

Hariprasad Shenai (4):
  cxgb4: Add support for dynamic allocation of resources for ULD
  cxgb4: Register changes and fw defines for crypto
  chcr: Support for Chelsio's Crypto Hardware
  crypto: Added Chelsio Menu to the Kconfig file

 drivers/crypto/Kconfig                          |    2 +
 drivers/crypto/Makefile                         |    1 +
 drivers/crypto/chelsio/Kconfig                  |   19 +
 drivers/crypto/chelsio/Makefile                 |    4 +
 drivers/crypto/chelsio/chcr_algo.c              | 1525 +++++++++++++++++++++++
 drivers/crypto/chelsio/chcr_algo.h              |  471 +++++++
 drivers/crypto/chelsio/chcr_core.c              |  240 ++++
 drivers/crypto/chelsio/chcr_core.h              |   80 ++
 drivers/crypto/chelsio/chcr_crypto.h            |  204 +++
 drivers/net/ethernet/chelsio/cxgb4/Makefile     |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   59 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  153 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c  |  555 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   34 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  437 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  126 ++-
 17 files changed, 3866 insertions(+), 50 deletions(-)
 create mode 100644 drivers/crypto/chelsio/Kconfig
 create mode 100644 drivers/crypto/chelsio/Makefile
 create mode 100644 drivers/crypto/chelsio/chcr_algo.c
 create mode 100644 drivers/crypto/chelsio/chcr_algo.h
 create mode 100644 drivers/crypto/chelsio/chcr_core.c
 create mode 100644 drivers/crypto/chelsio/chcr_core.h
 create mode 100644 drivers/crypto/chelsio/chcr_crypto.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c

-- 
1.7.3
