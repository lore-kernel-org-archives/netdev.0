From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: mlx5 broken affinity
Date: Wed, 1 Nov 2017 14:20:09 -0400
Message-ID: <f8624a01-f77a-ac0b-ba19-19c7150ca133@fb.com>
References: <2187e555-2c4e-ef55-1c3a-17f5af54d762@fb.com>
 <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Networking <netdev@vger.kernel.org>, <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Christoph Hellwig <hch@lst.de>
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36304 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751495AbdKASWP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 14:22:15 -0400
In-Reply-To: <d65d6156-07da-14dc-88ff-fcb5c0ef5f83@grimberg.me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 01:21 PM, Sagi Grimberg wrote:
>> Hi,
> 
> Hi Jes,
> 
>> The below patch seems to have broken PCI IRQ affinity assignments for
>> mlx5.
> 
> I wouldn't call it breaking IRQ affinity assignments. It just makes
> them automatic.

Well it explicitly breaks the option for an admin to assign them
manually, which contradicts what is written in
Documentation/IRQ-affinity.txt

>> Prior to this patch I could echo a value to /proc/irq/<x>/smp_affinity
>> and it would get assigned. With this patch applied I get -EIO
> 
> Adding Christoph,
> 
> Ideally the affinity assignments would be better left alone, but
> I wasn't aware that they are now immutable. Christoph?
> 
>> The actual affinity assignments seem to have changed too, but I assume
>> this is a result of the generic allocation?
> 
> The affinity assignments should be giving you perfect linear assignment
> of the rx/tx rings completion vectors to CPU cores:
> first  -> 0
> second -> 1
> third  -> 2
> ...
> 
> Before, mlx5 spread affinity starting from the local numa node as it
> relied on that when constructing RSS indirection table only to the local
> numa node (which as a side effect hurt applications running on the far
> node as the traffic was guaranteed to arrive rx rings located in the
> "wrong" node).
> 
> Now the RSS indirection table is linear across both numa nodes just like
> the irq affinity settings. Another thing that was improved was the
> pre/post vectors which blacklisted any non rx/tx completion vectors from
> the affinity assignments (like port events completion vectors from
> example).

I am all in favor of making the automatic setup better, but assuming an
automatic setup is always right seems problematic. There could be
workloads where you may want to assign affinity explicitly.

Jes
