From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 1/4] virtio_net: pass vi around
Date: Fri, 24 Oct 2014 10:02:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9DE6C2@AcuExch.aculab.com>
References: <1414099656-28090-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414099656-28090-1-git-send-email-mst@redhat.com>
Content-Language: en-US
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

From: Michael S. Tsirkin
 
> Too many places poke at [rs]q->vq->vdev->priv just to get
> the the vi structure.  Let's just pass the pointer around: seems
> cleaner, and might even be faster.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 36 +++++++++++++++++++-----------------
>  1 file changed, 19 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 57cbc7d..36f3dfc 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
...
>  static struct sk_buff *receive_big(struct net_device *dev,
> +				   struct virtnet_info *vi,

Do you need to pass 'dev' here?
Looks like it is obtainable from vi->dev (as below).

	David

>  				   struct receive_queue *rq,
>  				   void *buf,
>  				   unsigned int len)
>  {
>  	struct page *page = buf;
> -	struct sk_buff *skb = page_to_skb(rq, page, 0, len, PAGE_SIZE);
> +	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
...
> -static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
> +static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
> +			void *buf, unsigned int len)
>  {
> -	struct virtnet_info *vi = rq->vq->vdev->priv;
>  	struct net_device *dev = vi->dev;
...
