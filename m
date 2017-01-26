From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net resend] virtio_net: reject XDP programs using header
 adjustment
Date: Thu, 26 Jan 2017 10:57:54 +0800
Message-ID: <feba25b3-c423-a93c-f6b9-4f52bf159efc@redhat.com>
References: <5888C9B7.8040603@gmail.com>
 <20170125225636.167620-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, john.fastabend@gmail.com,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52080 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752453AbdAZC6C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 21:58:02 -0500
In-Reply-To: <20170125225636.167620-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月26日 06:56, Jakub Kicinski wrote:
> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
> added a new XDP helper to prepend and remove data from a frame.
> Make virtio_net reject programs making use of this helper until
> proper support is added.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   drivers/net/virtio_net.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f9bf94887ff1..a2aac4fd8e42 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1710,6 +1710,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>   	u16 xdp_qp = 0, curr_qp;
>   	int i, err;
>   
> +	if (prog && prog->xdp_adjust_head) {
> +		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
> +		return -EOPNOTSUPP;
> +	}
> +
>   	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>   	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
>   	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||

Acked-by: Jason Wang <jasowang@redhat.com>
