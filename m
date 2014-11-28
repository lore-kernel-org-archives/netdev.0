From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 29/46] vhost: add memory access wrappers
Date: Fri, 28 Nov 2014 08:43:01 +0008
Message-ID: <1417163701.5822.8@smtp.corp.redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-30-git-send-email-mst@redhat.com>
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
In-Reply-To: <1417118789-18231-30-git-send-email-mst@redhat.com>
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
> Add guest memory access wrappers to handle virtio endianness
> conversions.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/vhost.h | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index c624b09..1f321fd 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -176,4 +176,35 @@ static inline int vhost_has_feature(struct 
> vhost_virtqueue *vq, int bit)
>  {
>  	return vq->acked_features & (1ULL << bit);
>  }
> +
> +/* Memory accessors */
> +static inline u16 vhost16_to_cpu(struct vhost_virtqueue *vq, 
> __virtio16 val)
> +{
> +	return __virtio16_to_cpu(vhost_has_feature(vq, VIRTIO_F_VERSION_1), 
> val);
> +}
> +
> +static inline __virtio16 cpu_to_vhost16(struct vhost_virtqueue *vq, 
> u16 val)
> +{
> +	return __cpu_to_virtio16(vhost_has_feature(vq, VIRTIO_F_VERSION_1), 
> val);
> +}
> +
> +static inline u32 vhost32_to_cpu(struct vhost_virtqueue *vq, 
> __virtio32 val)
> +{
> +	return __virtio32_to_cpu(vhost_has_feature(vq, VIRTIO_F_VERSION_1), 
> val);
> +}
> +
> +static inline __virtio32 cpu_to_vhost32(struct vhost_virtqueue *vq, 
> u32 val)
> +{
> +	return __cpu_to_virtio32(vhost_has_feature(vq, VIRTIO_F_VERSION_1), 
> val);
> +}
> +
> +static inline u64 vhost64_to_cpu(struct vhost_virtqueue *vq, 
> __virtio64 val)
> +{
> +	return __virtio64_to_cpu(vhost_has_feature(vq, VIRTIO_F_VERSION_1), 
> val);
> +}
> +
> +static inline __virtio64 cpu_to_vhost64(struct vhost_virtqueue *vq, 
> u64 val)
> +{
> +	return __cpu_to_virtio64(vhost_has_feature(vq, VIRTIO_F_VERSION_1), 
> val);
> +}
>  #endif
> -- 
> MST

Reviewed-by: Jason Wang <jasowang@redhat.com>
