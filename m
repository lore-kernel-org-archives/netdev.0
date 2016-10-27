From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Thu, 27 Oct 2016 17:42:18 -0400 (EDT)
Message-ID: <20161027.174218.654961317277160121.davem@davemloft.net>
References: <20161027105514.4c0374dd@redhat.com>
        <58126CF4.5090500@gmail.com>
        <20161028002814-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, brouer@redhat.com, shrijeet@gmail.com,
        tom@herbertland.com, netdev@vger.kernel.org,
        shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964833AbcJ0VmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 17:42:22 -0400
In-Reply-To: <20161028002814-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 28 Oct 2016 00:30:35 +0300

> Something I'd like to understand is how does XDP address the
> problem that 100Byte packets are consuming 4K of memory now.

Via page pools.  We're going to make a generic one, but right now
each and every driver implements a quick list of pages to allocate
from (and thus avoid the DMA man/unmap overhead, etc.)
