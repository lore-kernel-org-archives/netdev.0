From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 0/3] net_dma removal and a new dma-debug check
Date: Tue, 17 Dec 2013 16:15:33 -0800
Message-ID: <20131218001312.7847.9917.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dmaengine@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET_DMA violates the expectation of the dma-mapping api by allowing the
cpu to touch receive buffer memory while dma is active.  If this
activity triggers a copy-on-write event the application may see missing
data as the dma completes to the old mapping.

[PATCH 1/3] net_dma: mark broken
Detail the failure and provide a small one-liner for -stable

[PATCH 2/3] net_dma: remove
Mark the tcp_dma_copybreak sysctl as removed and remove the rest of the
implementation

[PATCH 3/3] dma debug: flag copy-on-write events to pages undergoing dma
Extend dma-debug to catch this condition in the future.

Looking to take this through the dmaengine tree with a netdev ack.

---

 Documentation/ABI/removed/net_dma      |    8 +
 Documentation/networking/ip-sysctl.txt |    6 -
 drivers/dma/Kconfig                    |   11 -
 drivers/dma/Makefile                   |    1 
 drivers/dma/dmaengine.c                |  104 ------------
 drivers/dma/ioat/dma.c                 |    1 
 drivers/dma/ioat/dma.h                 |    7 -
 drivers/dma/ioat/dma_v2.c              |    1 
 drivers/dma/ioat/dma_v3.c              |    1 
 drivers/dma/iovlock.c                  |  280 --------------------------------
 include/linux/dma-debug.h              |    6 +
 include/linux/dmaengine.h              |   22 ---
 include/linux/skbuff.h                 |    7 -
 include/linux/tcp.h                    |    7 -
 include/net/netdma.h                   |   32 ----
 include/net/sock.h                     |   18 --
 include/net/tcp.h                      |    7 -
 kernel/sysctl_binary.c                 |    1 
 lib/dma-debug.c                        |  130 +++++++++++++--
 mm/memory.c                            |    3 
 net/core/Makefile                      |    1 
 net/core/dev.c                         |   10 -
 net/core/sock.c                        |    6 -
 net/core/user_dma.c                    |  131 ---------------
 net/dccp/proto.c                       |    4 
 net/ipv4/sysctl_net_ipv4.c             |    9 -
 net/ipv4/tcp.c                         |  147 ++---------------
 net/ipv4/tcp_input.c                   |   61 -------
 net/ipv4/tcp_ipv4.c                    |   18 --
 net/ipv6/tcp_ipv6.c                    |   13 -
 net/llc/af_llc.c                       |   10 +
 31 files changed, 161 insertions(+), 902 deletions(-)
 create mode 100644 Documentation/ABI/removed/net_dma
 delete mode 100644 drivers/dma/iovlock.c
 delete mode 100644 include/net/netdma.h
 delete mode 100644 net/core/user_dma.c
