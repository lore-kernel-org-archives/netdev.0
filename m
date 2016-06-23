From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: vmw_vsock sk_ack_backlog double decrement bug
Date: Thu, 23 Jun 2016 16:40:59 +0100
Message-ID: <20160623154059.GA2470@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: netdev@vger.kernel.org
To: jhansen@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265AbcFWPlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 11:41:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jorgen,
virtio-vsock doesn't use vsock_pending_work() but I may have spotted a
problem that affects the VMCI transport.  I'm not sending a patch
because I can't test it.

1. During vsock_accept() listener->sk_ack_backlog is decremented.
2. vsock_pending_work() will decrement listener->sk_ack_backlog again if
   vsk->rejected.

The result is that sk_ack_backlog can be invalid.  It only happens in
the case where the listener socket has an error.  Maybe in practice it's
not a problem because the server application will close the listener
socket if there is an error...

Stefan

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXbAMLAAoJEJykq7OBq3PIvZkH/3qiH/EgUFFXymu1X2aPav7N
JY5ghj7aM9CaZNGmOkCYGqCEpW4F76lElGWtGwoy0u40fCpY3sFy7F93wLnqWsGj
VxubuX1jHcz+xhgFI9PTQMR6UTPujyb/0lJ+J8EzffNoA6S9SkDqMzQp0eM4sfQA
75ZyDTkdS2gqFOmgBKK8YbtYLwH8jhDQ9LGSCiXSaV+MyfezabmGabG+gB6hVvK6
ddCuBZmxmNEOc3te8SFBaOfJWt63yQDHc6k64JbY1KnyR8umqGEMOz1wtPquYcXg
zzmkAzBpFbGB2DM4hYW0enR8T1bcfS7aG7NMjkysTSm5LX3+/t5pYmfLDpLoapY=
=++nh
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
