From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 11:11:49 +0200
Message-ID: <20151130111124-mutt-send-email-mst@redhat.com>
References: <1448872427-11623-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1448872427-11623-1-git-send-email-mst@redhat.com>
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

On Mon, Nov 30, 2015 at 10:34:07AM +0200, Michael S. Tsirkin wrote:
> We know vring num is a power of 2, so use &
> to mask the high bits.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/vhost.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 080422f..85f0f0a 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1366,10 +1366,12 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>  	/* Only get avail ring entries after they have been exposed by guest. */
>  	smp_rmb();
>  
> +	}
> +

Oops. This sneaked in from an unrelated patch.
Pls ignore, will repost.

>  	/* Grab the next descriptor number they're advertising, and increment
>  	 * the index we've seen. */
>  	if (unlikely(__get_user(ring_head,
> -				&vq->avail->ring[last_avail_idx % vq->num]))) {
> +				&vq->avail->ring[last_avail_idx & (vq->num - 1)]))) {
>  		vq_err(vq, "Failed to read head: idx %d address %p\n",
>  		       last_avail_idx,
>  		       &vq->avail->ring[last_avail_idx % vq->num]);
> @@ -1489,7 +1491,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
>  	u16 old, new;
>  	int start;
>  
> -	start = vq->last_used_idx % vq->num;
> +	start = vq->last_used_idx & (vq->num - 1);
>  	used = vq->used->ring + start;
>  	if (count == 1) {
>  		if (__put_user(heads[0].id, &used->id)) {
> @@ -1531,7 +1533,7 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
>  {
>  	int start, n, r;
>  
> -	start = vq->last_used_idx % vq->num;
> +	start = vq->last_used_idx & (vq->num - 1);
>  	n = vq->num - start;
>  	if (n < count) {
>  		r = __vhost_add_used_n(vq, heads, n);
> -- 
> MST
