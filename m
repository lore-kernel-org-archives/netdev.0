From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [net-next RFC V5 2/5] virtio_ring: move queue_index to
	vring_virtqueue
Date: Thu, 26 Jul 2012 10:20:02 +0200
Message-ID: <5010FDB2.5040505@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-3-git-send-email-jasowang@redhat.com>
	<1341488454.18786.15.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, mashirle@us.ibm.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1341488454.18786.15.camel@lappy>
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

Il 05/07/2012 13:40, Sasha Levin ha scritto:
> @@ -275,7 +274,7 @@ static void vm_del_vq(struct virtqueue *vq)
>         vring_del_virtqueue(vq);
>  
>         /* Select and deactivate the queue */
> -       writel(info->queue_index, vm_dev->base + VIRTIO_MMIO_QUEUE_SEL);
> +       writel(virtqueue_get_queue_index(vq), vm_dev->base + VIRTIO_MMIO_QUEUE_SEL);
>         writel(0, vm_dev->base + VIRTIO_MMIO_QUEUE_PFN);
>  

This accesses vq after vring_del_virtqueue has freed it.

Paolo
