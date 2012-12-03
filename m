From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [net-next rfc v7 1/3] virtio-net: separate fields of
	sending/receiving queue from virtnet_info
Date: Mon, 03 Dec 2012 12:25:42 +1030
Message-ID: <87y5hfj3vl.fsf@rustcorp.com.au>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
	<1354011360-39479-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com,
	kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com, krkumar2@in.ibm.com,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354011360-39479-2-git-send-email-jasowang@redhat.com>
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

Jason Wang <jasowang@redhat.com> writes:
> To support multiqueue transmitq/receiveq, the first step is to separate queue
> related structure from virtnet_info. This patch introduce send_queue and
> receive_queue structure and use the pointer to them as the parameter in
> functions handling sending/receiving.

OK, seems like a straightforward xform: a few nit-picks:

> +/* Internal representation of a receive virtqueue */
> +struct receive_queue {
> +	/* Virtqueue associated with this receive_queue */
> +	struct virtqueue *vq;
> +
> +        struct napi_struct napi;
> +
> +        /* Number of input buffers, and max we've ever had. */
> +        unsigned int num, max;

Weird whitespace here.

> +
> +	/* Work struct for refilling if we run low on memory. */
> +	struct delayed_work refill;

I can't really see the justificaiton for a refill per queue.  Just have
one work iterate all the queues if it happens, unless it happens often
(in which case, we need to look harder at this anyway).

>  struct virtnet_info {
>  	struct virtio_device *vdev;
> -	struct virtqueue *rvq, *svq, *cvq;
> +	struct virtqueue *cvq;
>  	struct net_device *dev;
>  	struct napi_struct napi;

You leave napi here, and take it away in the next patch.  I think it's
supposed to go away now.

Cheers,
Rusty.
