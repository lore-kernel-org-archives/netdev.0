From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net resend] virtio_net: reject XDP programs using header
 adjustment
Date: Thu, 26 Jan 2017 05:01:25 +0200
Message-ID: <20170126050114-mutt-send-email-mst@kernel.org>
References: <5888C9B7.8040603@gmail.com>
 <20170125225636.167620-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752453AbdAZDB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 22:01:26 -0500
Content-Disposition: inline
In-Reply-To: <20170125225636.167620-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 02:56:36PM -0800, Jakub Kicinski wrote:
> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
> added a new XDP helper to prepend and remove data from a frame.
> Make virtio_net reject programs making use of this helper until
> proper support is added.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f9bf94887ff1..a2aac4fd8e42 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1710,6 +1710,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  	u16 xdp_qp = 0, curr_qp;
>  	int i, err;
>  
> +	if (prog && prog->xdp_adjust_head) {
> +		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
> +		return -EOPNOTSUPP;
> +	}
> +
>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>  	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
>  	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
> -- 
> 2.11.0
