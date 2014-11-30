From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v7 28/46] vhost: make features 64 bit
Date: Sun, 30 Nov 2014 18:44:33 +0300
Message-ID: <547B3B61.3090801@cogentembedded.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-29-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417359787-10138-29-git-send-email-mst@redhat.com>
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

Hello.

On 11/30/2014 6:11 PM, Michael S. Tsirkin wrote:

> We need to use bit 32 for virtio 1.0

> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Reviewed-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/vhost/vhost.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 3eda654..c624b09 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -106,7 +106,7 @@ struct vhost_virtqueue {
>   	/* Protected by virtqueue mutex. */
>   	struct vhost_memory *memory;
>   	void *private_data;
> -	unsigned acked_features;
> +	u64 acked_features;
>   	/* Log write descriptors */
>   	void __user *log_base;
>   	struct vhost_log *log;
> @@ -174,6 +174,6 @@ enum {
>
>   static inline int vhost_has_feature(struct vhost_virtqueue *vq, int bit)
>   {
> -	return vq->acked_features & (1 << bit);
> +	return vq->acked_features & (1ULL << bit);

    Erm, wouldn't the high word be just dropped when returning *int*? I think 
you need !!(vq->acked_features & (1ULL << bit)).

[...]

WBR, Sergei
