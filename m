From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC v5 0/5] Add virtio transport for AF_VSOCK
Date: Wed, 13 Apr 2016 14:38:44 +0100
Message-ID: <20160413133844.GE9272@stefanha-x1.localdomain>
References: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
	<1460129705.1749.25.camel@docker.com>
	<20160411104548.GA12826@stefanha-x1.localdomain>
	<20160411154517-mutt-send-email-mst@redhat.com>
	<20160412135957.GB29405@stefanha-x1.localdomain>
	<CAOc2ZU1Kaes-UVfFrKrE9QyLMWnAQ77+hkSAGJgD0gOuM8o_UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8471023980913578178=="
Cc: marius vlad <marius.vlad0@gmail.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, ijc@hellion.org.uk,
	virtualization@lists.linux-foundation.org,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Matt Benjamin <mbenjamin@redhat.com>, netdev@vger.kernel.org,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Christoffer Dall <christoffer.dall@linaro.org>
To: Ian Campbell <ian.campbell@docker.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAOc2ZU1Kaes-UVfFrKrE9QyLMWnAQ77+hkSAGJgD0gOuM8o_UQ@mail.gmail.com>
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


--===============8471023980913578178==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vv4Sf/kQfcwinyKX"
Content-Disposition: inline


--vv4Sf/kQfcwinyKX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 12, 2016 at 05:37:54PM +0100, Ian Campbell wrote:
> Perhaps the guest end is turning shutdown(foo) directly into a vsock
> message without or-ing in the current state?

Yes, you are right:

  lock_sock(sk);
  sk->sk_shutdown |= mode;
  sk->sk_state_change(sk);
  release_sock(sk);

  if (sk->sk_type == SOCK_STREAM) {
      sock_reset_flag(sk, SOCK_DONE);
      vsock_send_shutdown(sk, mode);

Although sk_shutdown is ORed correctly, vsock_send_shutdown() is called with
just the shutdown() argument.

--vv4Sf/kQfcwinyKX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXDkvjAAoJEJykq7OBq3PIr8AIAI9hLqLWfXLLf3d416wjMf5c
h2/E0DX9GQ9BcWMlazKFevOuwo+RxwYOfeewiOj921be+NTVCbx/RnbtOWSOMHYN
iP/kiIWj1tIQ0DigwNjH8+jRV8V/x0yVgMst8xkVWaa/OOfQYXfa7TDVSIbrc2W+
TK9AQ+Qp9ZXEyDLnjw7GILYa8y9Iwt/BuE4q1v0ToHufRaR3Ayw1ozmsWG25z2En
1bSSN3HuSJNTIDeISALiTmV+3cUYGZVXmxs56RHuzr7s5YhMii3w0KxeslwTB/Lq
tHN07L0hRHPHALhINMfEvVvr8RVjEPfWUCWBbp8Bzbw5HGoarjmLn7EBdeyIO68=
=Cup7
-----END PGP SIGNATURE-----

--vv4Sf/kQfcwinyKX--

--===============8471023980913578178==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8471023980913578178==--
