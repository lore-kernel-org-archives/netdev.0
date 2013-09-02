From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 1/6] vhost_net: make vhost_zerocopy_signal_used()
	returns void
Date: Mon, 2 Sep 2013 08:51:18 +0300
Message-ID: <20130902055118.GB19838@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1377836962-49780-2-git-send-email-jasowang@redhat.com>
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

tweak subj s/returns/return/

On Fri, Aug 30, 2013 at 12:29:17PM +0800, Jason Wang wrote:
> None of its caller use its return value, so let it return void.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 969a859..280ee66 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -276,8 +276,8 @@ static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
>   * of used idx. Once lower device DMA done contiguously, we will signal KVM
>   * guest used idx.
>   */
> -static int vhost_zerocopy_signal_used(struct vhost_net *net,
> -				      struct vhost_virtqueue *vq)
> +static void vhost_zerocopy_signal_used(struct vhost_net *net,
> +				       struct vhost_virtqueue *vq)
>  {
>  	struct vhost_net_virtqueue *nvq =
>  		container_of(vq, struct vhost_net_virtqueue, vq);
> @@ -297,7 +297,6 @@ static int vhost_zerocopy_signal_used(struct vhost_net *net,
>  	}
>  	if (j)
>  		nvq->done_idx = i;
> -	return j;
>  }
>  
>  static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> -- 
> 1.7.1
