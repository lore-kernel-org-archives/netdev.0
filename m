From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v3 3/4] vsock: add pkt cancel capability
Date: Fri, 9 Dec 2016 10:16:09 +0000
Message-ID: <20161209101609.GB18260@stefanha-x1.localdomain>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-2-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-3-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-4-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3937407351069114447=="
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>, David Miller <davem@davemloft.net>,
	Jorgen Hansen <jhansen@vmware.com>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481217156-7160-4-git-send-email-bergwolf@gmail.com>
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


--===============3937407351069114447==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CdrF4e02JqNVZeln"
Content-Disposition: inline


--CdrF4e02JqNVZeln
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 09, 2016 at 01:12:35AM +0800, Peng Tao wrote:
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  net/vmw_vsock/virtio_transport.c | 42 ++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 42 insertions(+)
>=20
> diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_tran=
sport.c
> index 936d7ee..95c1162 100644
> --- a/net/vmw_vsock/virtio_transport.c
> +++ b/net/vmw_vsock/virtio_transport.c
> @@ -170,6 +170,47 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *p=
kt)
>  	return len;
>  }
> =20
> +static int
> +virtio_transport_cancel_pkt(struct vsock_sock *vsk)
> +{
> +	struct virtio_vsock *vsock;
> +	struct virtio_vsock_pkt *pkt, *n;
> +	int cnt =3D 0;
> +	LIST_HEAD(freeme);
> +
> +	vsock =3D virtio_vsock_get();
> +	if (!vsock) {
> +		return -ENODEV;
> +	}
> +
> +	spin_lock_bh(&vsock->send_pkt_list_lock);
> +	list_for_each_entry_safe(pkt, n, &vsock->send_pkt_list, list) {
> +		if (pkt->cancel_token !=3D (void *)vsk)

The cast is unnecessary here.

--CdrF4e02JqNVZeln
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSoRpAAoJEJykq7OBq3PI19YIAJDa6EL1EnJ377CRCoMGU5dz
A16gD6oCzschHS3NJEkjdlJqK579LRcdD799JAe7PzyuSJMnRX6QZFT2B58ZiWoB
vPVBoc6dK7ejD/sRmfmIHdH7Bammy/vR4kOsJyJUMJylFTkaT+nw7Ave57MujmgQ
gu+sUPKFSGHGN+n6h0qkBf1QdY206e+hBgSnkAp8w5CUy2rmHUbEmV2UFdPvQI06
8s2QtSXvvUeauSyvnjNu+xSSUF+CUHUl57k4JyemEOYxz9QnnIY+YqdqoVfBluSu
EEE/GuI54qkq6W1CBIf/Zhy33A6BYE6MhaauFc42Zh7Q/WMPznON8d7XhvorhqA=
=2rLH
-----END PGP SIGNATURE-----

--CdrF4e02JqNVZeln--

--===============3937407351069114447==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============3937407351069114447==--
