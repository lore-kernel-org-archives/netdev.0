From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] IB/ipoib: move back IB LL address into the hard
 header
Date: Fri, 14 Oct 2016 10:55:09 -0400 (EDT)
Message-ID: <20161014.105509.96692421040954960.davem@davemloft.net>
References: <9fce9b87ecc4c5c4f03401359806f40b1dcd0eb3.1476374992.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        jgunthorpe@obsidianresearch.com, netdev@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcJNOzM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 10:55:12 -0400
In-Reply-To: <9fce9b87ecc4c5c4f03401359806f40b1dcd0eb3.1476374992.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 13 Oct 2016 18:26:56 +0200

> After the commit 9207f9d45b0a ("net: preserve IP control block
> during GSO segmentation"), the GSO CB and the IPoIB CB conflict.
> That destroy the IPoIB address information cached there,
> causing a severe performance regression, as better described here:
> 
> http://marc.info/?l=linux-kernel&m=146787279825501&w=2
> 
> This change moves the data cached by the IPoIB driver from the
> skb control lock into the IPoIB hard header, as done before
> the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len
> and use skb->cb to stash LL addresses").
> In order to avoid GRO issue, on packet reception, the IPoIB driver
> stash into the skb a dummy pseudo header, so that the received
> packets have actually a hard header matching the declared length.
> To avoid changing the connected mode maximum mtu, the allocated
> head buffer size is increased by the pseudo header length.
> 
> After this commit, IPoIB performances are back to pre-regression
> value.
> 
> v2 -> v3: rebased
> v1 -> v2: avoid changing the max mtu, increasing the head buf size
> 
> Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segmentation")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thanks.
