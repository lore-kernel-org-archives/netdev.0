From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 0/7] introduce Hyper-V VM Sockets(hvsock)
Date: Thu, 16 Jul 2015 16:58:59 +0100
Message-ID: <20150716155859.GA29366@stefanha-thinkpad.redhat.com>
References: <1436193575-26674-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	haiyangz@microsoft.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436193575-26674-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 06, 2015 at 07:39:35AM -0700, Dexuan Cui wrote:
> Hyper-V VM Sockets (hvsock) is a byte-stream based communication mechanism
> between Windowsd 10 (or later) host and a guest. It's kind of TCP over
> VMBus, but the transportation layer (VMBus) is much simpler than IP.
> With Hyper-V VM Sockets, applications between the host and a guest can
> talk with each other directly by the traditional BSD-style socket APIs.
>=20
> The patchset implements the necessary support in the guest side by adding
> the necessary new APIs in the vmbus driver, and introducing a new driver
> hv_sock.ko, which implements_a new socket address family AF_HYPERV.
>=20
>=20
> I know the kernel has already had a VM Sockets driver (AF_VSOCK) based
> on VMware's VMCI (net/vmw_vsock/, drivers/misc/vmw_vmci), and KVM is
> proposing AF_VSOCK of virtio version:
> http://thread.gmane.org/gmane.linux.network/365205.
>=20
> However, though Hyper-V VM Sockets may seem conceptually similar to
> AF_VOSCK, there are differences in the transportation layer, and IMO these
> make the direct code reusing impractical:
>=20
> 1. In AF_VSOCK, the endpoint type is: <u32 ContextID, u32 Port>, but in
> AF_HYPERV, the endpoint type is: <GUID VM_ID, GUID ServiceID>. Here GUID
> is 128-bit.
>=20
> 2. AF_VSOCK supports SOCK_DGRAM, while AF_HYPERV doesn't.
>=20
> 3. AF_VSOCK supports some special sock opts, like SO_VM_SOCKETS_BUFFER_SI=
ZE,
> SO_VM_SOCKETS_BUFFER_MIN/MAX_SIZE and SO_VM_SOCKETS_CONNECT_TIMEOUT.
> These are meaningless to AF_HYPERV.
>=20
> 4. Some AF_VSOCK's VMCI transportation ops are meanless to AF_HYPERV/VMBu=
s,
> like    .notify_recv_init
>         .notify_recv_pre_block
>         .notify_recv_pre_dequeue
>         .notify_recv_post_dequeue
>         .notify_send_init
>         .notify_send_pre_block
>         .notify_send_pre_enqueue
>         .notify_send_post_enqueue
> etc.
>=20
> So I think we'd better introduce a new address family: AF_HYPERV.

Points 2-4 are not critical.  I think there are solutions to them.

Point 1 is the main issue: hvsock has <GUID, GUID> addresses instead of
vsock's <u32, u32> addresses.  Perhaps a mapping could be used but that
is pretty ugly.  One idea is something like a userspace <GUID, GUID> <->
<u32, u32> lookup function that applications can use if they want to
accept GUIDs.

I don't have a workable alternative to propose, so I agree that a new
address family is justified.

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVp9TDAAoJEJykq7OBq3PIKSwH/2whZ3vgcaadqT2QXAQYN8Qf
kxPE0vvZQsLalZR3WSlrSIpERku4jIWHTU03nXn0FkDrdv9TbErUuPnpAlOZiT+Z
KxxeBn4HyXCalZ8AdXdbyoe9DLuhY3BRSaxnMjymnEekHVYbqXakF/yxPYsKV6b0
qJQhf3Mq/XRiOQ+V8ULM+TCcUa6zwctmDzYE4vAPAlcy7M4iqqD6gviAlnoSRruF
0iwXvVDr5a+CFA8DiBGAm9pBgni3gRxpurJL95IZHlUU7QIM6EF/ZwP2cGmpl8gH
v/zR9BFvs1JyJCu3dOTl8mUE608HoKpBGDdyqlNjHuUqklqXOFf3cwTRthhgoEY=
=HtMK
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
