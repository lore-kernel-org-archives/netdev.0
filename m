From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: virtio: remove obsolete virtqueue_get_queue_index()
Date: Thu, 21 Mar 2013 10:01:46 +0100
Message-ID: <20130321100146.7a741c75@gondolin>
References: <878v5hp6hc.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <mst@redhat.com>, <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:58030 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab3CUKSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 06:18:38 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cornelia.huck@de.ibm.com>;
	Thu, 21 Mar 2013 10:15:43 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 84C653130698
	for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 09:02:32 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2L91euQ52232414
	for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 09:01:40 GMT
Received: from d06av11.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2L91m5o010047
	for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 03:01:49 -0600
In-Reply-To: <878v5hp6hc.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Mar 2013 17:47:03 +1030
Rusty Russell <rusty@rustcorp.com.au> wrote:

> You can access it directly now, since 3.8: v3.7-rc1-13-g06ca287
> 'virtio: move queue_index and num_free fields into core struct
> virtqueue.'
> 
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 

> diff --git a/drivers/s390/kvm/virtio_ccw.c b/drivers/s390/kvm/virtio_ccw.c
> index 2029b6c..a7eddc7 100644
> --- a/drivers/s390/kvm/virtio_ccw.c
> +++ b/drivers/s390/kvm/virtio_ccw.c
> @@ -166,7 +166,7 @@ static void virtio_ccw_kvm_notify(struct virtqueue *vq)
> 
>  	vcdev = to_vc_device(info->vq->vdev);
>  	ccw_device_get_schid(vcdev->cdev, &schid);
> -	do_kvm_notify(schid, virtqueue_get_queue_index(vq));
> +	do_kvm_notify(schid, vq->index);
>  }
> 
>  static int virtio_ccw_read_vq_conf(struct virtio_ccw_device *vcdev,
> @@ -188,7 +188,7 @@ static void virtio_ccw_del_vq(struct virtqueue *vq, struct ccw1 *ccw)
>  	unsigned long flags;
>  	unsigned long size;
>  	int ret;
> -	unsigned int index = virtqueue_get_queue_index(vq);
> +	unsigned int index = vq->index;
> 
>  	/* Remove from our list. */
>  	spin_lock_irqsave(&vcdev->lock, flags);
> @@ -610,7 +610,7 @@ static struct virtqueue *virtio_ccw_vq_by_ind(struct virtio_ccw_device *vcdev,
>  	vq = NULL;
>  	spin_lock_irqsave(&vcdev->lock, flags);
>  	list_for_each_entry(info, &vcdev->virtqueues, node) {
> -		if (virtqueue_get_queue_index(info->vq) == index) {
> +		if (vq->index == index) {

Should be
		if (info->vq->index == index) {

>  			vq = info->vq;
>  			break;
>  		}
