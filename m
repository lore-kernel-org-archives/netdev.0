From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] Virtio_net: Set dev->needed_headroom to put
 the header in
Date: Fri, 25 Apr 2014 16:51:25 +0800
Message-ID: <535A220D.7040101@redhat.com>
References: <60A73B7A161A82449A7DB7B382BFD1553702849A@SZXEMA504-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qinchuanyu <qinchuanyu@huawei.com>,
	Liuyongan <liuyongan@huawei.com>
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342AbaDYIwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 04:52:25 -0400
In-Reply-To: <60A73B7A161A82449A7DB7B382BFD1553702849A@SZXEMA504-MBS.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2014 11:11 AM, Zhangjie (HZ) wrote:
>
> This patch is a small supplement for Patch =93virtio-net: put virtio-=
net
> header inline with data=94.
>
> This patch set dev->needed_headroom for virtio-net device to put
> virtio-net header in.
>
> Currently, TCP packages have enough room, but UDP packages do not.
>
> For UDP packages, sk_buff is alloced in fun __ip_append_data. The siz=
e
> equals =93alloclen + hh_len + 15=94, and =93hh_len =3D
> LL_RESERVED_SPACE(rt->dst.dev);=94.
>
> The Macro is defined as follows:
>
> #define LL_RESERVED_SPACE(dev) \
>
> ((((dev)->hard_header_len+(dev)->needed_headroom)&~(HH_DATA_MOD - 1))
> + HH_DATA_MOD)
>
> By default, for UDP packages, after skb is allocated, only 16 bytes
> reserved. And 2 bytes remained after mac header is set. Not enough to
> put virtio-net header in.
>
> If we set dev->needed_headroom to 12 or 10 (according to
> mergeable_rx_bufs is on or off ), more room can be reserved.
>
> Then there is enough room for UDP packages to put the header in.
>
> Here is the patch. J
>
> ------------
>
> From a0192e935855002bb122a373a526fe884173c652 Mon Sep 17 00:00:00 200=
1
>
> From: ZhangJie <zhangjie14@huawei.com>
>
> Date: Fri, 25 Apr 2014 11:06:27 +0800
>
> Subject: [PATCH] set needed_headroom
>
> ---
>
> drivers/net/virtio_net.c | 7 +++++++
>
> 1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>
> index 7b68746..c95d196 100644
>
> --- a/drivers/net/virtio_net.c
>
> +++ b/drivers/net/virtio_net.c
>
> @@ -1724,6 +1724,13 @@ static int virtnet_probe(struct virtio_device
> *vdev)
>
> if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>
> vi->has_cvq =3D true;
>
> + if (vi->any_header_sg) {
>
> + if (vi->mergeable_rx_bufs)
>
> + dev->needed_headroom =3D sizeof(struct virtio_net_hdr_mrg_rxbuf);
>
> + else
>
> + dev->needed_headroom =3D sizeof(struct virtio_net_hdr);
>
> + }
>
> +
>
> /* Use single tx/rx queue pair as default */
>
> vi->curr_queue_pairs =3D 1;
>
> vi->max_queue_pairs =3D max_queue_pairs;
>
> --=20
>
> 1.7.10.msysgit.1
>
> --Best Wishes!
>
> //Zhang Jie
>

Hi:

Please submit a formal patch that obeys the rule of
Documentation/SubmittingPatches. Then you verify this by checking
whether or not it was captured by patchwork:
http://patchwork.ozlabs.org/project/netdev/list/.

=46or this patch, it's better to put your test method and result in the
commit log also.

Thanks
