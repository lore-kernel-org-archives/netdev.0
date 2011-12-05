From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Mon, 5 Dec 2011 10:55:13 +0000
Message-ID: <CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
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

On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang <jasowang@redhat.com> wrote:
> +static int virtnet_set_fd(struct net_device *dev, u32 pfn)
> +{
> + =A0 =A0 =A0 struct virtnet_info *vi =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct virtio_device *vdev =3D vi->vdev;
> +
> + =A0 =A0 =A0 if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_FD)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->config->set(vdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 offseto=
f(struct virtio_net_config_fd, addr),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &pfn, s=
izeof(u32));

Please use the virtio model (i.e. virtqueues) instead of shared
memory.  Mapping a page breaks the virtio abstraction.

Stefan
