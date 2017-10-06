From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Thu, 05 Oct 2017 17:20:13 -0700 (PDT)
Message-ID: <20171005.172013.746380495399822.davem@davemloft.net>
References: <CY1PR0701MB2012A2F8E3E923D98B1E1A6488700@CY1PR0701MB2012.namprd07.prod.outlook.com>
        <20171005.120629.2161199733119811102.davem@davemloft.net>
        <CY1PR0701MB201241C43A192735A0F1EEDD88700@CY1PR0701MB2012.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        dledford@redhat.com, Ariel.Elior@cavium.com
To: Michal.Kalderon@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54030 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751432AbdJFAUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 20:20:15 -0400
In-Reply-To: <CY1PR0701MB201241C43A192735A0F1EEDD88700@CY1PR0701MB2012.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Date: Thu, 5 Oct 2017 20:27:22 +0000

> The spinlock is required for the case that rx buffers are posted
> from a different thread, where it could be run simultaneously to the
> rxq_completion.

This only brings us back to my original argument, if the lock is
necessary in order to synchronize with those paths, how can you
possible drop the lock safely here?

Is it because you re-read the head and tail pointers of the queue each
time around the loop?
