From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next RFC 2/5] vhost: introduce helper to prefetch
	desc index
Date: Fri, 22 Sep 2017 10:02:57 +0100
Message-ID: <20170922090257.GB9243@stefanha-x1.localdomain>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
	<1506067355-5771-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1506067355-5771-3-git-send-email-jasowang@redhat.com>
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

On Fri, Sep 22, 2017 at 04:02:32PM +0800, Jason Wang wrote:
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index f87ec75..8424166d 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -2437,6 +2437,61 @@ struct vhost_msg_node *vhost_dequeue_msg(struct vhost_dev *dev,
>  }
>  EXPORT_SYMBOL_GPL(vhost_dequeue_msg);
>  
> +int vhost_prefetch_desc_indices(struct vhost_virtqueue *vq,
> +				struct vring_used_elem *heads,
> +				u16 num, bool used_update)

Missing doc comment.

> +{
> +	int ret, ret2;
> +	u16 last_avail_idx, last_used_idx, total, copied;
> +	__virtio16 avail_idx;
> +	struct vring_used_elem __user *used;
> +	int i;

The following variable names are a little confusing:

last_avail_idx vs vq->last_avail_idx.  last_avail_idx is a wrapped
avail->ring[] index, vq->last_avail_idx is a free-running counter.  The
same for last_used_idx vs vq->last_used_idx.

num argument vs vq->num.  The argument could be called nheads instead to
make it clear that this is heads[] and not the virtqueue size.

Not a bug but it took me a while to figure out what was going on.
