From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v4 0/4] vsock: cancel connect packets when failing to
	connect
Date: Mon, 9 Jan 2017 10:06:07 +0000
Message-ID: <20170109100607.GA30228@stefanha-x1.localdomain>
References: <1481545269-18104-1-git-send-email-bergwolf@gmail.com>
	<20161213095010.GA3103@stefanha-x1.localdomain>
	<CA+a=Yy7d940_OfNL=b_qZjnpRVL5pywKFpubtS_h6OtB7c2Dmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6980452452719759876=="
Cc: kvm@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>, David Miller <davem@davemloft.net>,
	Jorgen Hansen <jhansen@vmware.com>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+a=Yy7d940_OfNL=b_qZjnpRVL5pywKFpubtS_h6OtB7c2Dmg@mail.gmail.com>
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


--===============6980452452719759876==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Content-Disposition: inline


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 06, 2017 at 10:22:56AM +0800, Peng Tao wrote:
> On Tue, Dec 13, 2016 at 5:50 PM, Stefan Hajnoczi <stefanha@gmail.com> wro=
te:
> > On Mon, Dec 12, 2016 at 08:21:05PM +0800, Peng Tao wrote:
> >> Currently, if a connect call fails on a signal or timeout (e.g., guest=
 is still
> >> in the process of starting up), we'll just return to caller and leave =
the connect
> >> packet queued and they are sent even though the connection is consider=
ed a failure,
> >> which can confuse applications with unwanted false connect attempt.
> >>
> >> The patchset enables vsock (both host and guest) to cancel queued pack=
ets when
> >> a connect attempt is considered to fail.
> >>
> >> v4 changelog:
> >>   - drop two unnecessary void * cast
> >>   - update new callback commnet
> >> v3 changelog:
> >>   - define cancel_pkt callback in struct vsock_transport rather than s=
truct virtio_transport
> >>   - rename virtio_vsock_pkt->vsk to virtio_vsock_pkt->cancel_token
> >> v2 changelog:
> >>   - fix queued_replies counting and resume tx/rx when necessary
> >>
> >> Cheers,
> >> Tao
> >>
> >> Peng Tao (4):
> >>   vsock: track pkt owner vsock
> >>   vhost-vsock: add pkt cancel capability
> >>   vsock: add pkt cancel capability
> >>   vsock: cancel packets when failing to connect
> >>
> >>  drivers/vhost/vsock.c                   | 41 ++++++++++++++++++++++++=
++++++++
> >>  include/linux/virtio_vsock.h            |  2 ++
> >>  include/net/af_vsock.h                  |  3 +++
> >>  net/vmw_vsock/af_vsock.c                | 14 +++++++++++
> >>  net/vmw_vsock/virtio_transport.c        | 42 ++++++++++++++++++++++++=
+++++++++
> >>  net/vmw_vsock/virtio_transport_common.c |  7 ++++++
> >>  6 files changed, 109 insertions(+)
> >>
> >> --
> >> 2.7.4
> >>
> >> _______________________________________________
> >> Virtualization mailing list
> >> Virtualization@lists.linux-foundation.org
> >> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
> >
> > Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> ping~
>=20
> It looks like the patchsets are reviewed but not merged. Is there any blo=
cker?

If Jorgen is sending pull requests then it should go through him.

Otherwise David Miller could apply it.

Stefan

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYc2COAAoJEJykq7OBq3PInE8H/0OEbRqcrkt/4/k5h9sDuQN+
qj0iF2vPuVTPmP6cje/q6DG99e4sbwyU1OocRtGjilncNOguiUUH12QWw7VXrUFK
K3jHHz4IWb++z+euhyRFBXz9m8WDb+XKk0zk14T7uz6xoR1TXuCHkqsWrGU5TK9P
CadR0LXNzTV3J2S+4LfMBOMzp/mPEiugbjcTL166XsjAnF+KFmQj8eX/BoOD8pwY
NQ2/zojz8Kk8NgqbX4XCb8VNX9zzhsBOTChnCpgYVAFmI+KbdIN0qm5LeWHS2aAM
M48j7vDqY0SFb3uAQQWcY+r0sEQ2Fiylbp7fpn8l9VF3ZWsPwBmi2Knp5w9JHZ0=
=cZK8
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--

--===============6980452452719759876==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============6980452452719759876==--
