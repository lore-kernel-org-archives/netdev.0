From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH V2 1/2] vhost: convert pre sorted vhost memory array
	to interval tree
Date: Thu, 28 Apr 2016 14:20:32 +0800
Message-ID: <5721ABB0.8070509@redhat.com>
References: <1458873274-13961-1-git-send-email-jasowang@redhat.com>
	<1458873274-13961-2-git-send-email-jasowang@redhat.com>
	<20160427142948-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160427142948-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On 04/27/2016 07:30 PM, Michael S. Tsirkin wrote:
> On Fri, Mar 25, 2016 at 10:34:33AM +0800, Jason Wang wrote:
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
> Does this affect performance at all?
>

In pktgen test, no difference.

Thanks
