From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Subject: [Patch-V2 0/3] crypto/chcr: Add Chelsio Crypto Driver
Date: Mon, 18 Jul 2016 22:42:12 -0700
Message-ID: <1468906935-6770-1-git-send-email-yeshaswi@chelsio.com>
Cc: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linux-crypto@vger.kernel.org, jlulla@chelsio.ccom,
	harsh@chelsio.com, atul.gupta@chelsio.com,
	herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

This patch series contains 3 patches that add support for Chelsio's
Crypto Hardware.

The patch series has been created against Herbert Xu's tree (crypto-2.6).
It includes patches for Chelsio Low Level Driver(cxgb4) and adds the new
crypto Upper Layer Driver(chcr) under a new directory drivers/crypto/chelsio.

The first of the patch series implements necessary changes in the Chelsio
LLD for queue allocation, deallocation and registration of the ULD.

The second patch implements the Chelsio crypto driver.

The third patch contains the changes to the driver/crypto/Kconfig and
drivers/crypto/Makefile to enable the Chelsio Crypto driver.

We have included all the maintainers of respective drivers. Kindly
review the changes and provide feedback on the same.

Thank you Joe Perches and Herbert Xu for your review, I have made appropriate
changes based on them.

[V1 -> V2]

1. Some residual code cleanup
2. Adds pr_fmt with chcr (KBUILD_MODNAME) added
3. Changes var name to accomodate them <80 columns in the chcr_register_alg
4. Support for printing the crypto queue stats
5. Fix compile warnings reported by kbuild bot for certain architectures
6. Dependency fix in Kconfig.
7. If the request has the MAY_BACKLOG bit set and hardware queue is full the request
   is queued up else -EBUSY is returned to throttle the user. The queue when executed
   and processed returns -EINPROGRESS in completion.

Yeshaswi M R Gowda (3):
  cxgb4: Add Chelsio LLD support Chelsio Crypto ULD
  chcr: Support for Chelsio's Crypto Hardware
  crypto: Added Chelsio Menu to the Kconfig file

 drivers/crypto/Kconfig                             |    2 +
 drivers/crypto/Makefile                            |    1 +
 drivers/crypto/chelsio/Kconfig                     |   21 +
 drivers/crypto/chelsio/Makefile                    |    4 +
 drivers/crypto/chelsio/chcr_algo.c                 | 1509 ++++++++++++++++++++
 drivers/crypto/chelsio/chcr_algo.h                 |  503 +++++++
 drivers/crypto/chelsio/chcr_core.c                 |  268 ++++
 drivers/crypto/chelsio/chcr_core.h                 |   80 ++
 drivers/crypto/chelsio/chcr_crypto.h               |  204 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   18 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   41 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   80 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   10 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   64 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  437 ++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  131 +-
 16 files changed, 3362 insertions(+), 11 deletions(-)
 create mode 100644 drivers/crypto/chelsio/Kconfig
 create mode 100644 drivers/crypto/chelsio/Makefile
 create mode 100644 drivers/crypto/chelsio/chcr_algo.c
 create mode 100644 drivers/crypto/chelsio/chcr_algo.h
 create mode 100644 drivers/crypto/chelsio/chcr_core.c
 create mode 100644 drivers/crypto/chelsio/chcr_core.h
 create mode 100644 drivers/crypto/chelsio/chcr_crypto.h

-- 
1.7.10.1
