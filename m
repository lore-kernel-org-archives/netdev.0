From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/1] net: cdc_ncm: Reduce memory use when kernel
 memory low
Date: Mon, 03 Jul 2017 01:51:10 -0700 (PDT)
Message-ID: <20170703.015110.427054107771151934.davem@davemloft.net>
References: <1498682129-9129-1-git-send-email-jim_baxter@mentor.com>
        <1498682129-9129-2-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, oliver@neukum.org, bjorn@mork.no,
        David.Laight@ACULAB.COM
To: jim_baxter@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498682129-9129-2-git-send-email-jim_baxter@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Baxter <jim_baxter@mentor.com>
Date: Wed, 28 Jun 2017 21:35:29 +0100

> The CDC-NCM driver can require large amounts of memory to create
> skb's and this can be a problem when the memory becomes fragmented.
> 
> This especially affects embedded systems that have constrained
> resources but wish to maximise the throughput of CDC-NCM with 16KiB
> NTB's.
> 
> The issue is after running for a while the kernel memory can become
> fragmented and it needs compacting.
> If the NTB allocation is needed before the memory has been compacted
> the atomic allocation can fail which can cause increased latency,
> large re-transmissions or disconnections depending upon the data
> being transmitted at the time.
> This situation occurs for less than a second until the kernel has
> compacted the memory but the failed devices can take a lot longer to
> recover from the failed TX packets.
> 
> To ease this temporary situation I modified the CDC-NCM TX path to
> temporarily switch into a reduced memory mode which allocates an NTB
> that will fit into a USB_CDC_NCM_NTB_MIN_OUT_SIZE (default 2048 Bytes)
> sized memory block and only transmit NTB's with a single network frame
> until the memory situation is resolved.
> Each time this issue occurs we wait for an increasing number of
> reduced size allocations before requesting a full size one to not
> put additional pressure on a low memory system.
> 
> Once the memory is compacted the CDC-NCM data can resume transmitting
> at the normal tx_max rate once again.
> 
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>

Patch applied, thanks.
