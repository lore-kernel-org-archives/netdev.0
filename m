From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: enable big packets for large MTU values
Date: Wed, 29 Mar 2017 19:13:33 +0300
Message-ID: <20170329191324-mutt-send-email-mst@kernel.org>
References: <1490791079-22108-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490791079-22108-1-git-send-email-mst@redhat.com>
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

On Wed, Mar 29, 2017 at 03:38:09PM +0300, Michael S. Tsirkin wrote:
> If one enables e.g. jumbo frames without mergeable
> buffers, packets won't fit in 1500 byte buffers
> we use. Switch to big packet mode instead.
> TODO: make sizing more exact, possibly extend small
> packet mode to use larger pages.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Fixes: 14de9d114a82 ("virtio-net: Add initial MTU advice feature")

> ---
>  drivers/net/virtio_net.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index e0fb3707..9dc31dc 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -2428,6 +2428,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>  			dev->mtu = mtu;
>  			dev->max_mtu = mtu;
>  		}
> +
> +		/* TODO: size buffers correctly in this case. */
> +		if (dev->mtu > ETH_DATA_LEN)
> +			vi->big_packets = true;
>  	}
>  
>  	if (vi->any_header_sg)
> -- 
> MST
