From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: mlx5 broken affinity
Date: Thu, 2 Nov 2017 09:57:24 +0200
Message-ID: <9819bc7a-f560-2b6f-6ec2-41c9bb9ed6df@grimberg.me>
References: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
 <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
 <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>, leonro@mellanox.com,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Christoph Hellwig <hch@lst.de>,
        Thomas Gleixner <tglx@linutronix.de>
To: Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:49718 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdKBH52 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:57:28 -0400
Received: by mail-wm0-f68.google.com with SMTP id b189so8956296wmd.4
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 00:57:28 -0700 (PDT)
In-Reply-To: <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jes,

> I am all in favor of making the automatic setup better, but assuming an
> automatic setup is always right seems problematic. There could be
> workloads where you may want to assign affinity explicitly.

Adding Thomas to the thread.

My understanding that the thought is to prevent user-space from
messing up the nice linear assignment, but maybe this might be too
conservative?

The patch that prevented user-space from touching managed irq affinity
assignments:

--
commit 45ddcecbfa947f1dd8e8019bad9e90d6c9f2665c
Author: Thomas Gleixner <tglx@linutronix.de>
Date:   Mon Jul 4 17:39:25 2016 +0900

     genirq: Use affinity hint in irqdesc allocation

     Use the affinity hint in the irqdesc allocator. The hint is used to 
determine
     the node for the allocation and to set the affinity of the interrupt.

     If multiple interrupts are allocated (multi-MSI) then the allocator 
iterates
     over the cpumask and for each set cpu it allocates on their node 
and sets the
     initial affinity to that cpu.

     If a single interrupt is allocated (MSI-X) then the allocator uses 
the first
     cpu in the mask to compute the allocation node and uses the mask 
for the
     initial affinity setting.

     Interrupts set up this way are marked with the AFFINITY_MANAGED flag to
     prevent userspace from messing with their affinity settings.

     Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
     Cc: Christoph Hellwig <hch@lst.de>
     Cc: linux-block@vger.kernel.org
     Cc: linux-pci@vger.kernel.org
     Cc: linux-nvme@lists.infradead.org
     Cc: axboe@fb.com
     Cc: agordeev@redhat.com
     Link: 
http://lkml.kernel.org/r/1467621574-8277-5-git-send-email-hch@lst.de
     Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
