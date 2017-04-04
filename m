From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH rfc 5/6] block: Add rdma affinity based queue mapping
        helper
Date: Tue, 4 Apr 2017 15:09:26 +0200
Message-ID: <20170404130926.GA16338@lst.de>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me> <1491140492-25703-6-git-send-email-sagi@grimberg.me> <becb84ac-7819-a207-56b1-70f16cb80e42@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sagi Grimberg <sagi@grimberg.me>, linux-rdma@vger.kernel.org,
        linux-nvme@lists.infradead.org, linux-block@vger.kernel.org,
        netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: Max Gurtovoy <maxg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:51995 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752358AbdDDNJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 09:09:28 -0400
Content-Disposition: inline
In-Reply-To: <becb84ac-7819-a207-56b1-70f16cb80e42@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 04, 2017 at 10:46:54AM +0300, Max Gurtovoy wrote:
>> +	if (set->nr_hw_queues > dev->num_comp_vectors)
>> +		goto fallback;
>> +
>> +	for (queue = 0; queue < set->nr_hw_queues; queue++) {
>> +		mask = ib_get_vector_affinity(dev, first_vec + queue);
>> +		if (!mask)
>> +			goto fallback;
>
> Christoph,
> we can use fallback also in the blk-mq-pci.c in case pci_irq_get_affinity 
> fails, right ?

For PCI it shouldn't fail as the driver calling pci_irq_get_affinity
knows how it set up the interrupts.  So I don't think it's necessary there.
