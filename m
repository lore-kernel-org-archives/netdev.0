From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC] vhost: convert pre sorted vhost memory array to
 interval tree
Date: Wed, 20 Jan 2016 10:50:47 +0800
Message-ID: <569EF607.2070107@redhat.com>
References: <1453084949-4896-1-git-send-email-jasowang@redhat.com>
 <20160119162406.7f0c2008@nial.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Igor Mammedov <imammedo@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20160119162406.7f0c2008@nial.brq.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/19/2016 11:24 PM, Igor Mammedov wrote:
> On Mon, 18 Jan 2016 10:42:29 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> > Current pre-sorted memory region array has some limitations for future
>> > device IOTLB conversion:
>> > 
>> > 1) need extra work for adding and removing a single region, and it's
>> >    expected to be slow because of sorting or memory re-allocation.
>> > 2) need extra work of removing a large range which may intersect
>> >    several regions with different size.
>> > 3) need trick for a replacement policy like LRU
>> > 
>> > To overcome the above shortcomings, this patch convert it to interval
>> > tree which can easily address the above issue with almost no extra
>> > work.
>> > 
>> > The patch could be used for:
>> > 
>> > - Extend the current API and only let the userspace to send diffs of
>> >   memory table.
>> > - Simplify Device IOTLB implementation.
> I'm curios how performance changes on translate_desc() hot-path in
> default case and in the case of 256 memory regions?
>

Haven't measured this. But consider both methods are O(logN), should be
no noticeable difference. Will measure it in the future.

The main user is for the device IOTLB API[1], which:

- have thousands of userspace memory region sections
- may dynamically adding or removing one or some of the regions
- need a replacement algorithm like LRU

[1] https://lkml.org/lkml/2015/12/31/16
