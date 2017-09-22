From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next RFC 1/5] vhost: split out ring head fetching
 logic
Date: Fri, 22 Sep 2017 09:31:58 +0100
Message-ID: <20170922083157.GA9243@stefanha-x1.localdomain>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506067355-5771-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 04:02:31PM +0800, Jason Wang wrote:
> +/* This looks in the virtqueue and for the first available buffer, and converts
> + * it to an iovec for convenient access.  Since descriptors consist of some
> + * number of output then some number of input descriptors, it's actually two
> + * iovecs, but we pack them into one and note how many of each there were.
> + *
> + * This function returns the descriptor number found, or vq->num (which is
> + * never a valid descriptor number) if none was found.  A negative code is
> + * returned on error. */
> +int __vhost_get_vq_desc(struct vhost_virtqueue *vq,
> +			struct iovec iov[], unsigned int iov_size,
> +			unsigned int *out_num, unsigned int *in_num,
> +			struct vhost_log *log, unsigned int *log_num,
> +			__virtio16 head)
[...]
> +int vhost_get_vq_desc(struct vhost_virtqueue *vq,
> +		      struct iovec iov[], unsigned int iov_size,
> +		      unsigned int *out_num, unsigned int *in_num,
> +		      struct vhost_log *log, unsigned int *log_num)

Please document vhost_get_vq_desc().

Please also explain the difference between __vhost_get_vq_desc() and
vhost_get_vq_desc() in the documentation.
