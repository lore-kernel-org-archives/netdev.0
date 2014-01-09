From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 0/4] net_dma removal, and dma debug extension
Date: Thu, 09 Jan 2014 12:12:26 -0800
Message-ID: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dmaengine@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22892 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757074AbaAIUMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 15:12:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow up patches to 77873803363c "net_dma: mark broken" to remove
net_dma bits and provide debug infrastructure to flag other
get_user_pages() vs dma instances that might violate the dma api.

Will takes this through the dmaengine tree once acked.

Changes since v1 [1]:

1/ net_dma removal patch has been expanded to revert other
   net_dma induced changes.

2/ updated the debug_dma_assert_idle() api to be gated on
   CONFIG_DMA_VS_CPU_DEBUG

---

Dan Williams (4):
      net_dma: simple removal
      net_dma: revert 'copied_early'
      net: make tcp_cleanup_rbuf private
      dma debug: introduce debug_dma_assert_idle()


 Documentation/ABI/removed/net_dma      |    8 +
 Documentation/networking/ip-sysctl.txt |    6 -
 drivers/dma/Kconfig                    |   12 -
 drivers/dma/Makefile                   |    1 
 drivers/dma/dmaengine.c                |  104 ------------
 drivers/dma/ioat/dma.c                 |    1 
 drivers/dma/ioat/dma.h                 |    7 -
 drivers/dma/ioat/dma_v2.c              |    1 
 drivers/dma/ioat/dma_v3.c              |    1 
 drivers/dma/iovlock.c                  |  280 --------------------------------
 include/linux/dma-debug.h              |    6 +
 include/linux/dmaengine.h              |   22 ---
 include/linux/skbuff.h                 |    8 -
 include/linux/tcp.h                    |    8 -
 include/net/netdma.h                   |   32 ----
 include/net/sock.h                     |   19 --
 include/net/tcp.h                      |    9 -
 kernel/sysctl_binary.c                 |    1 
 lib/Kconfig.debug                      |   13 +
 lib/dma-debug.c                        |  130 +++++++++++++--
 mm/memory.c                            |    3 
 net/core/Makefile                      |    1 
 net/core/dev.c                         |   10 -
 net/core/sock.c                        |    6 -
 net/core/user_dma.c                    |  131 ---------------
 net/dccp/proto.c                       |    4 
 net/ipv4/sysctl_net_ipv4.c             |    9 -
 net/ipv4/tcp.c                         |  157 ++----------------
 net/ipv4/tcp_input.c                   |   83 +--------
 net/ipv4/tcp_ipv4.c                    |   18 --
 net/ipv6/tcp_ipv6.c                    |   13 -
 net/llc/af_llc.c                       |   10 +
 32 files changed, 186 insertions(+), 928 deletions(-)
 create mode 100644 Documentation/ABI/removed/net_dma
 delete mode 100644 drivers/dma/iovlock.c
 delete mode 100644 include/net/netdma.h
 delete mode 100644 net/core/user_dma.c
