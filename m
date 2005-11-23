From: Andrew Grover <andrew.grover@intel.com>
Subject: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 12:26:28 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: john.ronciak@intel.com, <christopher.leech@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932344AbVKWU1I@vger.kernel.org>
To: netdev@vger.kernel.org, <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As presented in our talk at this year's OLS, the Bensley platform, which 
will be out in early 2006, will have an asyncronous DMA engine. It can be 
used to offload copies from the CPU, such as the kernel copies of received 
packets into the user buffer.

The code consists of the following sections:
1) The HW driver for the DMA engine device
2) The DMA subsystem, which abstracts the HW details from users of the 
async DMA
3) Modifications to net/ to make use of the DMA engine for receive copy 
offload:
    3a) Code to register the net stack as a "DMA client"
    3b) Code to pin and unpin pages associated with a user buffer
    3c) Code to initiate async DMA transactions in the net receive path

Today we are releasing 2, 3a, and 3b, as well as "testclient", a throwaway
driver we wrote to demonstrate the DMA subsystem API. We will be releasing
3c shortly. We will be releasing 1 (the HW driver) when the platform ships
early next year. Until then, the code doesn't really *do* anything, but we
wanted to release what we could right away, and start getting some 
feedback.

Against 2.6.14:
patch 1: DMA engine
patch 2: iovec pin/unpin code; register net as a DMA client
patch 3: testclient

overall diffstat information:
 drivers/Kconfig           |    2 
 drivers/Makefile          |    1 
 drivers/dma/Kconfig       |   40 ++
 drivers/dma/Makefile      |    5 
 drivers/dma/cb_list.h     |   12 
 drivers/dma/dmaengine.c   |  394 ++++++++++++++++++++++++
 drivers/dma/testclient.c  |  132 ++++++++
 include/linux/dmaengine.h |  268 ++++++++++++++++
 net/core/Makefile         |    3 
 net/core/dev.c            |   78 ++++
 net/core/user_dma.c       |  422 ++++++++++++++++++++++++++
 11 files changed, 1356 insertions(+), 1 deletion(-)

Regards -- Andy and Chris
