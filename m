From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] virtio_net: enable napi after enabling new queues
Date: Wed, 22 May 2013 13:46:38 +0800
Message-ID: <519C5BBE.3060407@redhat.com>
References: <1369200149-11280-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Sasha Levin <sasha.levin@oracle.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1369200149-11280-1-git-send-email-jasowang@redhat.com>
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

On 05/22/2013 01:22 PM, Jason Wang wrote:
> Commit 55257d72bd1c51f25106350f4983ec19f62ed1fa (virtio-net: fill only rx
> queues which are being used) forgets to enable napi for new enabled queues which
> breaks the multiqueue receiving. This patch fixes it.
>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2d6abac..9b2f59f 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -914,9 +914,11 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
>  			 queue_pairs);
>  		return -EINVAL;
>  	} else {
> -		for (i = vi->curr_queue_pairs; i < queue_pairs; i++)
> +		for (i = vi->curr_queue_pairs; i < queue_pairs; i++) {
>  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
> +			virtnet_napi_enable(&vi->rq[i]);
> +		}
>  		vi->curr_queue_pairs = queue_pairs;
>  	}
>  
A bug were found in this patch, will send a new version.
