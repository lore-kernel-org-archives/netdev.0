From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC v4 0/5] Add virtio transport for AF_VSOCK
Date: Thu, 28 Jan 2016 15:19:56 +0000
Message-ID: <20160128151956.GA10369@stefanha-x1.localdomain>
References: <1450775258-18287-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3154595957281578739=="
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>, matt.ma@linaro.org
To: kvm@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1450775258-18287-1-git-send-email-stefanha@redhat.com>
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


--===============3154595957281578739==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 22, 2015 at 05:07:33PM +0800, Stefan Hajnoczi wrote:
> This series is based on v4.4-rc2 and the "virtio: make find_vqs()
> checkpatch.pl-friendly" patch I recently submitted.
>=20
> v4:
>  * Addressed code review comments from Alex Bennee
>  * MAINTAINERS file entries for new files
>  * Trace events instead of pr_debug()
>  * RST packet is sent when there is no listen socket
>  * Allow guest->host connections again (began discussing netfilter suppor=
t with
>    Matt Benjamin instead of hard-coding security policy in virtio-vsock c=
ode)
>  * Many checkpatch.pl cleanups (will be 100% clean in v5)
>=20
> v3:
>  * Remove unnecessary 3-way handshake, just do REQUEST/RESPONSE instead
>    of REQUEST/RESPONSE/ACK
>  * Remove SOCK_DGRAM support and focus on SOCK_STREAM first
>    (also drop v2 Patch 1, it's only needed for SOCK_DGRAM)
>  * Only allow host->guest connections (same security model as latest
>    VMware)
>  * Don't put vhost vsock driver into staging
>  * Add missing Kconfig dependencies (Arnd Bergmann <arnd@arndb.de>)
>  * Remove unneeded variable used to store return value
>    (Fengguang Wu <fengguang.wu@intel.com> and Julia Lawall
>    <julia.lawall@lip6.fr>)
>=20
> v2:
>  * Rebased onto Linux v4.4-rc2
>  * vhost: Refuse to assign reserved CIDs
>  * vhost: Refuse guest CID if already in use
>  * vhost: Only accept correctly addressed packets (no spoofing!)
>  * vhost: Support flexible rx/tx descriptor layout
>  * vhost: Add missing total_tx_buf decrement
>  * virtio_transport: Fix total_tx_buf accounting
>  * virtio_transport: Add virtio_transport global mutex to prevent races
>  * common: Notify other side of SOCK_STREAM disconnect (fixes shutdown
>    semantics)
>  * common: Avoid recursive mutex_lock(tx_lock) for write_space (fixes dea=
dlock)
>  * common: Define VIRTIO_VSOCK_TYPE_STREAM/DGRAM hardware interface const=
ants
>  * common: Define VIRTIO_VSOCK_SHUTDOWN_RCV/SEND hardware interface const=
ants
>  * common: Fix peer_buf_alloc inheritance on child socket
>=20
> This patch series adds a virtio transport for AF_VSOCK (net/vmw_vsock/).
> AF_VSOCK is designed for communication between virtual machines and
> hypervisors.  It is currently only implemented for VMware's VMCI transpor=
t.
>=20
> This series implements the proposed virtio-vsock device specification from
> here:
> http://permalink.gmane.org/gmane.comp.emulators.virtio.devel/980
>=20
> Most of the work was done by Asias He and Gerd Hoffmann a while back.  I =
have
> picked up the series again.
>=20
> The QEMU userspace changes are here:
> https://github.com/stefanha/qemu/commits/vsock
>=20
> Why virtio-vsock?
> -----------------
> Guest<->host communication is currently done over the virtio-serial devic=
e.
> This makes it hard to port sockets API-based applications and is limited =
to
> static ports.
>=20
> virtio-vsock uses the sockets API so that applications can rely on famili=
ar
> SOCK_STREAM semantics.  Applications on the host can easily connect to gu=
est
> agents because the sockets API allows multiple connections to a listen so=
cket
> (unlike virtio-serial).  This simplifies the guest<->host communication a=
nd
> eliminates the need for extra processes on the host to arbitrate virtio-s=
erial
> ports.
>=20
> Overview
> --------
> This series adds 3 pieces:
>=20
> 1. virtio_transport_common.ko - core virtio vsock code that uses vsock.ko
>=20
> 2. virtio_transport.ko - guest driver
>=20
> 3. drivers/vhost/vsock.ko - host driver
>=20
> Howto
> -----
> The following kernel options are needed:
>   CONFIG_VSOCKETS=3Dy
>   CONFIG_VIRTIO_VSOCKETS=3Dy
>   CONFIG_VIRTIO_VSOCKETS_COMMON=3Dy
>   CONFIG_VHOST_VSOCK=3Dm
>=20
> Launch QEMU as follows:
>   # qemu ... -device vhost-vsock-pci,id=3Dvhost-vsock-pci0,guest-cid=3D3
>=20
> Guest and host can communicate via AF_VSOCK sockets.  The host's CID (add=
ress)
> is 2 and the guest must be assigned a CID (3 in the example above).
>=20
> Status
> ------
> This patch series implements the latest draft specification.  Please revi=
ew.
>=20
> Asias He (4):
>   VSOCK: Introduce virtio_vsock_common.ko
>   VSOCK: Introduce virtio_transport.ko
>   VSOCK: Introduce vhost_vsock.ko
>   VSOCK: Add Makefile and Kconfig
>=20
> Stefan Hajnoczi (1):
>   VSOCK: transport-specific vsock_transport functions
>=20
>  MAINTAINERS                                        |  13 +
>  drivers/vhost/Kconfig                              |  15 +
>  drivers/vhost/Makefile                             |   4 +
>  drivers/vhost/vsock.c                              | 607 +++++++++++++++
>  drivers/vhost/vsock.h                              |   4 +
>  include/linux/virtio_vsock.h                       | 167 +++++
>  include/net/af_vsock.h                             |   3 +
>  .../trace/events/vsock_virtio_transport_common.h   | 144 ++++
>  include/uapi/linux/virtio_ids.h                    |   1 +
>  include/uapi/linux/virtio_vsock.h                  |  87 +++
>  net/vmw_vsock/Kconfig                              |  19 +
>  net/vmw_vsock/Makefile                             |   2 +
>  net/vmw_vsock/af_vsock.c                           |   9 +
>  net/vmw_vsock/virtio_transport.c                   | 481 ++++++++++++
>  net/vmw_vsock/virtio_transport_common.c            | 834 +++++++++++++++=
++++++
>  15 files changed, 2390 insertions(+)
>  create mode 100644 drivers/vhost/vsock.c
>  create mode 100644 drivers/vhost/vsock.h
>  create mode 100644 include/linux/virtio_vsock.h
>  create mode 100644 include/trace/events/vsock_virtio_transport_common.h
>  create mode 100644 include/uapi/linux/virtio_vsock.h
>  create mode 100644 net/vmw_vsock/virtio_transport.c
>  create mode 100644 net/vmw_vsock/virtio_transport_common.c

Michael and Jason: Ping

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWqjGcAAoJEJykq7OBq3PI+akIAKzMJ36S9Sr4r9UqM8M666nS
0Z0ubDi0hSf8IrrL4hQMzLcRrSMqPq/LeonbeYwUxxfIOc5UFsMiefx5FXPbVrp4
Tspq7NE6GAsxyFpwpsIdexQVlh24d6fJjWgD1T5hdaEHaWUcI03f4VMihECvjb9c
G9pf8z5b+ucO3vhD4dPGKHnGbhNWfZdejJFeWgTCT6vvJB3yfGjBswRGbHU+R+8d
yieI1WYZs6iDX9q7gXHB55IAtak2HJ8TftZu1EjbInc+soiriyei8p5t+AcZQiGN
VcetNhog0onhdjt1Q1nEeATaoLyuUfe5VkAz4aNutPi2KcoTnFTuOlVeWDMofqs=
=GsX1
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--

--===============3154595957281578739==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============3154595957281578739==--
