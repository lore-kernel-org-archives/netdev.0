From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: AF_VSOCK network namespace support
Date: Wed, 23 Nov 2016 14:55:35 +0000
Message-ID: <20161123145535.GA16465@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Cc: netdev@vger.kernel.org, imbrenda@linux.vnet.ibm.com
To: Jorgen Hansen <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38522 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938633AbcKWO43 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 09:56:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jorgen,
There are two use cases where network namespace support in AF_VSOCK
could be useful:

1. Claudio Imbrenda pointed out that a machine cannot act as both host
   and guest at the same time.  This is necessary for nested
   virtualization.  Currently only one transport (the host side or the
   guest side) can be registered at a time.

2. Users may wish to isolate the AF_VSOCK address namespace so that two
   VMs have completely independent CID and ports (they could even use
   the same CID and ports because they're in separate namespaces).  This
   ensures that a host service visible to VM1 is not automatically
   visible to VM2.

Network namespaces could solve both problems.

A drawback of namespaces is that existing configurations using network
namespaces for IPv4/6 or other purposes break if AF_VSOCK gains network
namespace support.  This is not a big problem for virtio-vsock if we
implement namespace support soon since there are no existing users.

I wonder how other address families have solved this transition to
network namespaces.  It's almost like we need fine-grained namespaces
instead of a blanket network namespace that applies across all address
families...

I'm playing around with the code now but wanted to get your thoughts in
case you've already considered these problems.

Stefan

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYNa3nAAoJEJykq7OBq3PISB8H/i6c2h4vmYrp14lr4z0nC8Zq
34eHSihEN2WksD9qVuvC6zw8vm7smHR1iaM5aFitAaQoaur4A+CxPlR+uWUlnJSt
pFV1azfN0C+WdshFCb5tILBKcrx06TtCcCp2DKyjtuuXLrt7GOSMcx/yoikbn/0R
yp59hLO4Nr0PvTb18Sosh9AXgFOVweMQuyxrTTKdVRed0LZtlvsExVWM6NlJ5Dm/
QXrDi1Dx+soKmjr+pYCGKqt4R714po0qtdlA0nu5bo30fiRpjESfkK2pfWTOMBki
1Qhrat6/J17ro2lf4czj6wNi+KQkoj3kFX1e1O2tt339z/TXbSkVm5ayWFcoTaM=
=CbZ/
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
