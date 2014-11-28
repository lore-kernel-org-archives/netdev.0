From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 28/46] vhost: make features 64 bit
Date: Fri, 28 Nov 2014 08:40:57 +0008
Message-ID: <1417163577.5822.7@smtp.corp.redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-29-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417118789-18231-29-git-send-email-mst@redhat.com>
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



On Fri, Nov 28, 2014 at 4:10 AM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> We need to use bit 32 for virtio 1.0
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/vhost.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 3eda654..c624b09 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -106,7 +106,7 @@ struct vhost_virtqueue {
>  	/* Protected by virtqueue mutex. */
>  	struct vhost_memory *memory;
>  	void *private_data;
> -	unsigned acked_features;
> +	u64 acked_features;
>  	/* Log write descriptors */
>  	void __user *log_base;
>  	struct vhost_log *log;
> @@ -174,6 +174,6 @@ enum {
>  
>  static inline int vhost_has_feature(struct vhost_virtqueue *vq, int 
> bit)
>  {
> -	return vq->acked_features & (1 << bit);
> +	return vq->acked_features & (1ULL << bit);
>  }
>  #endif
> -- 
> MST

Reviewed-by: Jason Wang <jasowang@redhat.com>
