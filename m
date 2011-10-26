From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Qemu-devel] [RFC v2 PATCH 4/4] virtio-net: notify guest to
 annouce itself
Date: Tue, 25 Oct 2011 23:19:29 -0700
Message-ID: <CAJSP0QVmrDC5S5+QmadEGN8GPT3WtC7RvO12sN3Fr5KMvp+SAA@mail.gmail.com>
References: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
	<20111022053907.21526.81697.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com,
	pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45877 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab1JZGTa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 02:19:30 -0400
In-Reply-To: <20111022053907.21526.81697.stgit@dhcp-8-146.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2011 at 10:39 PM, Jason Wang <jasowang@redhat.com> wrot=
e:
> diff --git a/hw/virtio-net.c b/hw/virtio-net.c
> index 8c2f460..7f844e7 100644
> --- a/hw/virtio-net.c
> +++ b/hw/virtio-net.c
> @@ -95,6 +95,10 @@ static void virtio_net_set_config(VirtIODevice *vd=
ev, const uint8_t *config)
> =A0 =A0 =A0 =A0 memcpy(n->mac, netcfg.mac, ETH_ALEN);
> =A0 =A0 =A0 =A0 qemu_format_nic_info_str(&n->nic->nc, n->mac);
> =A0 =A0 }
> +
> + =A0 =A0if (memcmp(&netcfg.status, &n->status, sizeof(n->status))) {
> + =A0 =A0 =A0 =A0memcpy(&n->status, &netcfg.status, sizeof(n->status)=
);
> + =A0 =A0}

The memcpy() can be done unconditionally.

> =A0}
>
> =A0static bool virtio_net_started(VirtIONet *n, uint8_t status)
> @@ -227,7 +231,7 @@ static uint32_t virtio_net_get_features(VirtIODev=
ice *vdev, uint32_t features)
> =A0{
> =A0 =A0 VirtIONet *n =3D to_virtio_net(vdev);
>
> - =A0 =A0features |=3D (1 << VIRTIO_NET_F_MAC);
> + =A0 =A0features |=3D (1 << VIRTIO_NET_F_MAC | 1 << VIRTIO_NET_F_GUE=
ST_ANNOUNCE);
>
> =A0 =A0 if (peer_has_vnet_hdr(n)) {
> =A0 =A0 =A0 =A0 tap_using_vnet_hdr(n->nic->nc.peer, 1);
> @@ -983,6 +987,19 @@ static void virtio_net_cleanup(VLANClientState *=
nc)
> =A0 =A0 n->nic =3D NULL;
> =A0}
>
> +static int virtio_net_announce(VLANClientState *nc)
> +{
> + =A0 =A0VirtIONet *n =3D DO_UPCAST(NICState, nc, nc)->opaque;
> +
> + =A0 =A0if (n->vdev.guest_features & (0x1 << VIRTIO_NET_F_GUEST_ANNO=
UNCE)) {
> + =A0 =A0 =A0 =A0n->status |=3D VIRITO_NET_S_ANNOUNCE;

Typo, should be VIRTIO_NET_S_ANNOUNCE.

Stefan
