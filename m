From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v4 0/4] vsock: cancel connect packets when failing to
	connect
Date: Tue, 13 Dec 2016 09:50:10 +0000
Message-ID: <20161213095010.GA3103@stefanha-x1.localdomain>
References: <1481545269-18104-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3983649470925062634=="
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>, David Miller <davem@davemloft.net>,
	Jorgen Hansen <jhansen@vmware.com>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481545269-18104-1-git-send-email-bergwolf@gmail.com>
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


--===============3983649470925062634==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Content-Disposition: inline


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 12, 2016 at 08:21:05PM +0800, Peng Tao wrote:
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
> v4 changelog:
>   - drop two unnecessary void * cast
>   - update new callback commnet
> v3 changelog:
>   - define cancel_pkt callback in struct vsock_transport rather than stru=
ct virtio_transport
>   - rename virtio_vsock_pkt->vsk to virtio_vsock_pkt->cancel_token
> v2 changelog:
>   - fix queued_replies counting and resume tx/rx when necessary
>=20
> Cheers,
> Tao
>=20
> Peng Tao (4):
>   vsock: track pkt owner vsock
>   vhost-vsock: add pkt cancel capability
>   vsock: add pkt cancel capability
>   vsock: cancel packets when failing to connect
>=20
>  drivers/vhost/vsock.c                   | 41 +++++++++++++++++++++++++++=
+++++
>  include/linux/virtio_vsock.h            |  2 ++
>  include/net/af_vsock.h                  |  3 +++
>  net/vmw_vsock/af_vsock.c                | 14 +++++++++++
>  net/vmw_vsock/virtio_transport.c        | 42 +++++++++++++++++++++++++++=
++++++
>  net/vmw_vsock/virtio_transport_common.c |  7 ++++++
>  6 files changed, 109 insertions(+)
>=20
> --=20
> 2.7.4
>=20
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYT8RSAAoJEJykq7OBq3PIGBkIALwKOTYa7ExTUKH0qBR/Bg4j
RHuw8kol8NjwAhPe/q53pNAg9TUTYSsQzEKcDS8kvtMP7aMvf1Xfq6qRVVxTPbtj
oiQTakVbMKXxciuQ4IWPrxbIP0taSonUWJsT1+2W4WOgVjxn2U5d7N0R3sWaawj5
g/t7YVp/80YWtn+FK0kXFfS7B33ySWHtLns5CA9rw+L0aFWVJZ+3izus7OxF0WRJ
TaCPoxmPIdbeOEwHxxTIYuu6dAzU+pULPO8HU3u9CxH3qg0Kb0Sm6OWllIXy753b
8sy3ce+z0G4uk6eYtIEvXd0WKN/BIbko7g5ymJ25wByG5dubQGAOvcuzWbuRo2Q=
=Q2Uv
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--

--===============3983649470925062634==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============3983649470925062634==--
