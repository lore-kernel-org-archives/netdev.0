From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v2 1/4] vsock: track pkt owner vsock
Date: Thu, 8 Dec 2016 09:30:10 +0000
Message-ID: <20161208093010.GC10780@stefanha-x1.localdomain>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
	<1481123652-80603-2-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9017287539538149145=="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481123652-80603-2-git-send-email-bergwolf@gmail.com>
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


--===============9017287539538149145==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vOmOzSkFvhd7u8Ms"
Content-Disposition: inline


--vOmOzSkFvhd7u8Ms
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 11:14:09PM +0800, Peng Tao wrote:
> So that we can cancel a queued pkt later if necessary.
>=20
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  include/linux/virtio_vsock.h            | 2 ++
>  net/vmw_vsock/virtio_transport_common.c | 7 +++++++
>  2 files changed, 9 insertions(+)
>=20
> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
> index 9638bfe..6dd3242 100644
> --- a/include/linux/virtio_vsock.h
> +++ b/include/linux/virtio_vsock.h
> @@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
>  	struct virtio_vsock_hdr	hdr;
>  	struct work_struct work;
>  	struct list_head list;
> +	struct vsock_sock *vsk;

To prevent future bugs, please add a comment here:
/* socket refcnt not held, only use for cancellation */

This field is just an opaque token used for cancellation rather than a
struct vsock_sock pointer that we are allowed to dereference.  You could
change this field to void *cancel_token to make the code harder to
misuse.

--vOmOzSkFvhd7u8Ms
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSSgiAAoJEJykq7OBq3PIl08H/1ahhqxx76VBWoFPU4Ry0UMD
aY2pex/imfzJIhC3J3YfyRwS9UHDpSj7SQdsGqlJbibJ2vevOvbTs69PoL5/v4Yv
8l3AEB0XbE/cZQu5PwbIx7a7wKTICt6QJNh9TXL9oUNCL3Zi+eAaKJ9VA6/QDguU
6zeGLPmXHhatfGYAp88JrQ9P2Yr5/COiWTCJdGFHEWF1Tm9yhjZubxpEMGv2Ce3X
/MGNQkHg9nb9j38CllACeG3GLVJPOYBCM/1orqPM+QmP7gzb6UzpT7QefUvY5GxQ
RIJZIXOF5cKBe2yLCnG+8kpaVlX7CMmfV1H2yX6xXUSY0RgnFITgMaAOllBm01U=
=OUDL
-----END PGP SIGNATURE-----

--vOmOzSkFvhd7u8Ms--

--===============9017287539538149145==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============9017287539538149145==--
