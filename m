From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: Update the mtu code to match virtio spec
Date: Tue, 25 Oct 2016 19:41:07 +0300
Message-ID: <20161025194036-mutt-send-email-mst@kernel.org>
References: <1477413335-17296-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jarod Wilson <jarod@redhat.com>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Aaron Conole <aconole@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1477413335-17296-1-git-send-email-aconole@redhat.com>
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

On Tue, Oct 25, 2016 at 12:35:35PM -0400, Aaron Conole wrote:
> From: Aaron Conole <aconole@bytheb.org>
> 
> The virtio committee recently ratified a change, VIRTIO-152, which
> defines the mtu field to be 'max' MTU, not simply desired MTU.
> 
> This commit brings the virtio-net device in compliance with VIRTIO-152.
> 
> Additionally, drop the max_mtu branch - it cannot be taken since the u16
> returned by virtio_cread16 will never exceed the initial value of
> max_mtu.
> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Aaron Conole <aconole@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 720809f..2cafd12 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1870,10 +1870,12 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		mtu = virtio_cread16(vdev,
>  				     offsetof(struct virtio_net_config,
>  					      mtu));
> -		if (mtu < dev->min_mtu || mtu > dev->max_mtu)
> +		if (mtu < dev->min_mtu) {
>  			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
> -		else
> +		} else {
>  			dev->mtu = mtu;
> +			dev->max_mtu = mtu;
> +		}
>  	}
>  
>  	if (vi->any_header_sg)
> -- 
> 2.7.4
