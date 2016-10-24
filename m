From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH RFC 19/26] arch/sparc: Add option to skip DMA
 sync as a part of map and unmap
Date: Mon, 24 Oct 2016 14:27:30 -0400 (EDT)
Message-ID: <20161024.142730.1316656811538193943.davem@davemloft.net>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
        <20161024120607.16276.5989.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, sparclinux@vger.kernel.org, brouer@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932470AbcJXS1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 14:27:32 -0400
In-Reply-To: <20161024120607.16276.5989.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:07 -0400

> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: sparclinux@vger.kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

This is fine for avoiding the flush for performance reasons, but the
chip isn't going to write anything back unless the device wrote into
the area.
