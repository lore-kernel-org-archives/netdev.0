From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC v5 net-next 4/6] virtio-net: add basic interrupt coalescing support
Date: Fri, 13 Feb 2015 13:22:09 +1030
Message-ID: <874mqqbk12.fsf@rustcorp.com.au>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com> <1423471165-34243-5-git-send-email-jasowang@redhat.com> <87386ey2iy.fsf@rustcorp.com.au> <20150210104019.GD9505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pagupta@redhat.com,
	Pawel Moll <pawel.moll@arm.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150210104019.GD9505@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Tue, Feb 10, 2015 at 12:02:37PM +1030, Rusty Russell wrote:
>> Jason Wang <jasowang@redhat.com> writes:
>> > This patch enables the interrupt coalescing setting through ethtool.
>> 
>> The problem is that there's nothing network specific about interrupt
>> coalescing.  I can see other devices wanting exactly the same thing,
>> which means we'd deprecate this in the next virtio standard.
>> 
>> I think the right answer is to extend like we did with
>> vring_used_event(), eg:
>> 
>> 1) Add a new feature VIRTIO_F_RING_COALESCE.
>> 2) Add another a 32-bit field after vring_used_event(), eg:
>>         #define vring_used_delay(vr) (*(u32 *)((vr)->avail->ring[(vr)->num + 2]))
>> 
>> This loses the ability to coalesce by number of frames, but we can still
>> do number of sg entries, as we do now with used_event, and we could
>> change virtqueue_enable_cb_delayed() to take a precise number if we
>> wanted.
>
> But do we expect delay to be update dynamically?
> If not, why not stick it in config space?

Hmm, we could update it dynamically (and will, in the case of ethtool).
But it won't be common, so we could append a field to
virtio_pci_common_cfg for PCI.

I think MMIO and CCW would be easy to extend too, but CC'd to check.

>> My feeling is that this should be a v1.0-only feature though
>> (eg. feature bit 33).
>
> Yes, e.g. we can't extend config space for legacy virtio pci.

Thanks,
Rusty.
