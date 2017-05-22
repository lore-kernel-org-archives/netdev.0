From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [Patch net] vsock: use new wait API for vsock_stream_sendmsg()
Date: Mon, 22 May 2017 14:56:05 +0100
Message-ID: <20170522135605.GC24772@stefanha-x1.localdomain>
References: <1495218119-12358-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="lCAWRPmW1mITcIfM"
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37768 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933574AbdEVN4J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 09:56:09 -0400
Content-Disposition: inline
In-Reply-To: <1495218119-12358-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lCAWRPmW1mITcIfM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 19, 2017 at 11:21:59AM -0700, Cong Wang wrote:
> As reported by Michal, vsock_stream_sendmsg() could still
> sleep at vsock_stream_has_space() after prepare_to_wait():
>=20
>   vsock_stream_has_space
>     vmci_transport_stream_has_space
>       vmci_qpair_produce_free_space
>         qp_lock
>           qp_acquire_queue_mutex
>             mutex_lock
>=20
> Just switch to the new wait API like we did for commit
> d9dc8b0f8b4e ("net: fix sleeping for sk_wait_event()").
>=20
> Reported-by: Michal Kubecek <mkubecek@suse.cz>
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/vmw_vsock/af_vsock.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--lCAWRPmW1mITcIfM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZIu31AAoJEJykq7OBq3PI5pYIAMg0IpK3Qspkq5ZCVAAhX63Z
3xgnmKKF5GJYmSmFS2P0ZMFxxICGwJAqQiv0uhf+JN03YNRX0/FPO00ES9noyXRN
6wrnVkzChnKI2MNc++3BOKd9tFvbhy0H0JhSSKbmwS4QeTY4JqVYP9QtXptkuu+9
Lm3rPTYgotbSBJ+eODcRBZ4zIVifiZPXPTWxuj0gJ+eHLS05HYyYPDqt9RjKCjEE
kb9EV84InHTdiHcoPF22bW6/K0+iyF3odkHcLQEABYSFJTzAEGEjjnHOMRPzcjQh
WIbZmmjpS9TSu+bLx27OFO0HXa1i2yNmYtKPYRS74Pf3385KR8AmI6xsBEz3ydo=
=aXJa
-----END PGP SIGNATURE-----

--lCAWRPmW1mITcIfM--
