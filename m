From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V5 2/5] virtio_ring: move queue_index to
	vring_virtqueue
Date: Mon, 30 Jul 2012 11:30:38 +0800
Message-ID: <5015FFDE.5030007@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-3-git-send-email-jasowang@redhat.com>
	<1341488454.18786.15.camel@lappy> <5010FDB2.5040505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, mashirle@us.ibm.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	Sasha Levin <levinsasha928@gmail.com>, jwhan@filewood.snu.ac.kr,
	sri@us.ibm.com, davem@davemloft.net, tahm@linux.vnet.ibm.com
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5010FDB2.5040505@redhat.com>
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

On 07/26/2012 04:20 PM, Paolo Bonzini wrote:
> Il 05/07/2012 13:40, Sasha Levin ha scritto:
>> @@ -275,7 +274,7 @@ static void vm_del_vq(struct virtqueue *vq)
>>          vring_del_virtqueue(vq);
>>
>>          /* Select and deactivate the queue */
>> -       writel(info->queue_index, vm_dev->base + VIRTIO_MMIO_QUEUE_SEL);
>> +       writel(virtqueue_get_queue_index(vq), vm_dev->base + VIRTIO_MMIO_QUEUE_SEL);
>>          writel(0, vm_dev->base + VIRTIO_MMIO_QUEUE_PFN);
>>
> This accesses vq after vring_del_virtqueue has freed it.
>
> Paolo
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Yes, so need a temporary variable before vring_del_virtqueue().

Thanks.
