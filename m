From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH-v5 0/4] vsock: cancel connect packets when failing to
	connect
Date: Thu, 16 Mar 2017 15:14:37 +0800
Message-ID: <20170316071437.GA17296@stefanha-x1.localdomain>
References: <1489541537-130429-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8578893806983484154=="
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1489541537-130429-1-git-send-email-bergwolf@gmail.com>
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


--===============8578893806983484154==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Content-Disposition: inline


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 15, 2017 at 09:32:13AM +0800, Peng Tao wrote:
> Currently, if a connect call fails on a signal or timeout (e.g., guest is=
 still
> in the process of starting up), we'll just return to caller and leave the=
 connect
> packet queued and they are sent even though the connection is considered =
a failure,
> which can confuse applications with unwanted false connect attempt.
>=20
> The patchset enables vsock (both host and guest) to cancel queued packets=
 when
> a connect attempt is considered to fail.
>=20
> v5 changelog:
>   - change virtio_vsock_pkt->cancel_token back to virtio_vsock_pkt->vsk

As discussed previously, it's an opaque token that is not interpreted or
dereferenced.  A unique integer could be used instead of the pointer we
conveniently use as the token today.  I still think it should be void *
or uintptr_t, but let's move on.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYyjtcAAoJEJykq7OBq3PIYZ4H+wSoBh/205nht7+rP7p+yhbS
pc/cNMeSUKjkWRuR3+yPuWVT/UgUa4Cz83L+KkjHMBLhwVPDhfaubChH7sIzFkG+
QAqJk0ro5edUf17PC1/sqhW7lYLx3U0gQPCFgHnbjvMpYMIwRqugwDXtxWkuEtet
ry5dptEHmp2+WNfaeWTfZkkR9/Nn23DyQMFpxD0FIWMtpZXXTtsVYLrZwWQ142kR
RPI/TZRhXyuB9iusQrsodvQCLGL1sbnaD7GXzZEgKNCxYbYbwWV1bazX/VI+xXSB
QjrUibTBDQ9oTF0DTIUrrvqY6YtLy8NrXxxOHqRQKS5J+3aObDFBIr6zvqBzE4U=
=uTSm
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--

--===============8578893806983484154==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8578893806983484154==--
