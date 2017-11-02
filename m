From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: mlx5 broken affinity
Date: Thu, 2 Nov 2017 12:08:43 +0200
Message-ID: <83d3944f-8a31-eb31-93db-294906630b0e@grimberg.me>
References: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
 <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
 <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
 <CALzJLG-Z2fJibyZ74XU7XCSx-g3=YapV9VyekAYZkS5JwvkwWw@mail.gmail.com>
 <573060a9-19a7-9133-ef52-fa947088dabb@fb.com>
 <3af0c164-8dde-b6f0-45e1-edbbb28e7f73@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Christoph Hellwig <hch@lst.de>,
        Thomas Gleixner <tglx@linutronix.de>
To: Tariq Toukan <tariqt@mellanox.com>,
        Jes Sorensen <jsorensen@fb.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:50855 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbdKBKIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 06:08:46 -0400
Received: by mail-wm0-f49.google.com with SMTP id s66so9759546wmf.5
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 03:08:46 -0700 (PDT)
In-Reply-To: <3af0c164-8dde-b6f0-45e1-edbbb28e7f73@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> I vaguely remember Nacking Sagi's patch as we knew it would break
>>> mlx5e netdev affinity assumptions.
> I remember that argument. Still the series found its way in.

Of course it maid its way in, it was acked by three different
maintainers, and I addressed all of Saeed's comments.

> That series moves affinity decisions to kernel's responsibility.
> AFAI see, what kernel does is assign IRQs to the NUMA's one by one in 
> increasing indexing (starting with cores of NUMA #0), no matter what 
> NUMA is closer to the NIC.

Well, as we said before, if there is a good argument to do the home node
first we can change the generic code (as it should be given that this is
absolutely not device specific).

> This means that if your NIC is on NUMA #1, and you reduce the number of 
> channels, you might end up working only with the cores on the far NUMA. 
> Not good!
We deliberated on this before, and concluded that application affinity
and device affinity are equally important. If you have a real use case
that shows otherwise, its perfectly doable to start from the device home
node.

>>> And I agree here that user should be able to read
>>> /proc/irq/x/smp_affinity and even modify it if required.
> Totally agree. We should fix that ASAP.
> User must have write access.

I'll let Thomas reply here, I do not fully understand the reason for why
pci_alloc_irq_vectors() make the affinity assignments immutable..
