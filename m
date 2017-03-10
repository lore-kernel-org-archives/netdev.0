From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH-v4-RESEND 1/4] vsock: track pkt owner vsock
Date: Fri, 10 Mar 2017 09:48:49 +0800
Message-ID: <20170310014849.GA3213@stefanha-x1.localdomain>
References: <1488340587-32416-1-git-send-email-bergwolf@gmail.com>
 <1488340587-32416-2-git-send-email-bergwolf@gmail.com>
 <20170302.131303.703202861280343181.davem@davemloft.net>
 <CA+a=Yy4T1WRZoYM3WPD0et7QzF0RYUtRerDS_X-dU5uABixTJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34203 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbdCJBsz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 20:48:55 -0500
Content-Disposition: inline
In-Reply-To: <CA+a=Yy4T1WRZoYM3WPD0et7QzF0RYUtRerDS_X-dU5uABixTJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 03, 2017 at 09:25:54AM +0800, Peng Tao wrote:
> On Fri, Mar 3, 2017 at 5:13 AM, David Miller <davem@davemloft.net> wrote:
> > From: Peng Tao <bergwolf@gmail.com>
> > Date: Wed,  1 Mar 2017 11:56:24 +0800
> >
> >> So that we can cancel a queued pkt later if necessary.
> >>
> >> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> >> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> >> ---
> >>  include/linux/virtio_vsock.h            | 2 ++
> >>  net/vmw_vsock/virtio_transport_common.c | 7 +++++++
> >>  2 files changed, 9 insertions(+)
> >>
> >> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock=
=2Eh
> >> index 9638bfe..193ad3a 100644
> >> --- a/include/linux/virtio_vsock.h
> >> +++ b/include/linux/virtio_vsock.h
> >> @@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
> >>       struct virtio_vsock_hdr hdr;
> >>       struct work_struct work;
> >>       struct list_head list;
> >> +     void *cancel_token; /* only used for cancellation */
> >
> > The type here is fixed, you only store vhost_sock object pointers
> > here, so don't use "void *" please.
> It used to be "struct vhost_sock *" but no refcount is held. Stefan
> suggested to use "void *cancel_token" to make the code harder to
> misuse.
>=20
> Quoting Stefan:
> "This field is just an opaque token used for cancellation rather than
> a struct vsock_sock pointer that we are allowed to dereference.  You
> could change this field to void *cancel_token to make the code harder
> to misuse."
>=20
> Ref:
> https://www.mail-archive.com/netdev@vger.kernel.org/msg142550.html

Yes, the key point is that it shouldn't be used as a struct vsock_sock
since we don't hold a reference.  It's purely a token so the queued
packet can be found later for cancellation.

Stefan

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYwgXjAAoJEJykq7OBq3PIAagH/jlhF0cxZftOpV775VFhc+Ra
hwUKuKRurMeFEoa8K+zVnbpTc06IJgCCtIxKMo8MHoB9qsyWZgwm7K2NACaKRCsX
kto1uuPnQTxlLnI4wiWxAfKPktHiQ0LIVfPga5vgGWjDIU/r0O5eKU0XwdVfQogi
R8JtSrjUoDLVoEq7tZHAQF7aZVeHbFIhBwZAVWEiJyDB01DbLUVKLHVm3lgrYysS
hwoFNLIzmGlDH5imPT1Pd+zxjJ9lV4MRLzH08WRifUy/Oglyspf8AWzERXwWIpCi
VO+Jl/0A3JaN5vmWpbj/CC54CUvWjoCewnSV3i2s8pMX8bDCTHmvbZB/xbphF4E=
=5siv
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
