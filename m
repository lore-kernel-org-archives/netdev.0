From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: AF_VSOCK unimplemented sockopts
Date: Tue, 15 Aug 2017 09:36:18 +0100
Message-ID: <20170815083618.GD32702@stefanha-x1.localdomain>
References: <20170803104116.GA22685@stefanha-x1.localdomain>
 <9D465B5B-5A07-4250-8AB3-DEC80CCC45B7@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="LKTjZJSUETSlgu2t"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36570 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752613AbdHOIgU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 04:36:20 -0400
Content-Disposition: inline
In-Reply-To: <9D465B5B-5A07-4250-8AB3-DEC80CCC45B7@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LKTjZJSUETSlgu2t
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11, 2017 at 09:23:17AM +0000, Jorgen S. Hansen wrote:
> > On Aug 3, 2017, at 12:41 PM, Stefan Hajnoczi <stefanha@redhat.com> wrot=
e:
> >=20
> > Hi Jorgen,
> > There are 3 sockopts defined in include/uapi/linux/vm_sockets.h that are
> > currently not implemented in net/vmw_vsock/af_vsock.c:
> >=20
> > * SO_VM_SOCKETS_PEER_HOST_VM_ID
> > * SO_VM_SOCKETS_TRUSTED
> > * SO_VM_SOCKETS_NONBLOCK_TXRX
> >=20
> > I noticed this because SO_VM_SOCKETS_TRUSTED is interesting for
> > virtio-vsock.  Services listening on AF_VSOCK inside the guest may not
> > want arbitrary unprivileged host processes to connect.  Instead of
> > inventing a new solution I wanted to look into SO_VM_SOCKETS_TRUSTED but
> > found it is not implemented in linux.git.
> >=20
> > What is the status of these sockets?
>=20
> These options were only implemented for ESX host endpoints, so were never=
 part of the Linux host side support. It looks like they could have been om=
itted from vm_sockets.h, when the initial upstreaming was performed.
>=20
> On ESX, the equivalent of SO_VM_SOCKETS_TRUSTED, is used for retrieving t=
he value of s->trusted of a VMCI socket. It cannot be used to mark a socket=
 as trusted. On Linux, trusted is tied to the CAP_NET_ADMIN capability of t=
he socket creator. VMCI based vSockets will per default only allow host sid=
e sockets that are trusted, or are created by the same user as the VM, to c=
ommunicate with a given VM. This is achieved by per default creating VMs wi=
th the VMCI privilege flag VMCI_PRIVILEGE_FLAG_RESTRICTED. It is possible t=
o create a VM that isn=E2=80=99t restricted, in which case any host process=
 will be able to communicate with the VM.
>=20
> So it should be straight forward to implement the getsockopt part of SO_V=
M_SOCKETS_TRUSTED, since it just needs to return s->trusted.

Currently virtio-vsock does not implement the 'restricted' mode but I'm
evaluating using it by default for stronger security.  Thanks for your
response!

Stefan

--LKTjZJSUETSlgu2t
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZkrKCAAoJEJykq7OBq3PI7OwH/1Hwgiku2/JlcGMlOX7npqEC
62sVablsbdcr8IRuzJfOjgDwC++tWWcd3TB0aI8MhNXPEzzIyaxLL5uWTFr5lRCC
32+X5EDlrxWrxccZGHvYhRWY1TbMs2JMVXCaPIJaeOmXjcVk3JqXsvyQ691paruc
PVkt0ImyplXJe13sykXc4eY8FXyQ7WbmBwhg8m3CnSepxtJR1d2r3Kp2bwzifjvB
d6m4TfffxARr+CJumP8Em71gnE7oQAifVK3xzleh7dMw6e3ONgKkmSlZQS0MGI6Y
ix0O/mO6sruaUIQI1IvbinQLAMdqRKUUFIEocO2scYgNejfJNnJGxkSgY7ZI+T8=
=M0kt
-----END PGP SIGNATURE-----

--LKTjZJSUETSlgu2t--
