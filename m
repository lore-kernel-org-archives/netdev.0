From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: AF_VSOCK loopback
Date: Thu, 10 Nov 2016 14:43:29 +0000
Message-ID: <20161110144329.GA19683@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: cavery@redhat.com, netdev@vger.kernel.org
To: Jorgen Hansen <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933541AbcKJOnb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 09:43:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jorgen,
Cathy Avery found that the AF_VSOCK VMCI transport does loopback inside
the guest (but not on the host?).  The virtio transport currently does
no loopback.

The loopback scenario I'm thinking of is where process A listens on port
1234 and process B on the same machine connects to port 1234 both with
the same CID.

I'd like to make the virtio transport compatible with VMCI transport
semantics so AF_VSOCK behaves the same regardless of the transport.
This means loopback must be added to virtio-vsock.

The core net/vmware/af_vsock.c code does not implement loopback.  How
does VMCI do loopback?  Are the loopback packets reflected back from the
host?  Or does the guest driver notice the loopback and avoid passing
packets to the host in the first place?

Maybe we can make the loopback code common in af_vsock.c if that avoids
code duplication.

Thanks,
Stefan

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYJIeRAAoJEJykq7OBq3PInSAH/ivngCLpPeZLcw4YVOVSx2Gd
kaWc2Y+4rc5qXW5SW6HNlMqY7KT/YU3CDTw7O+3efc3zh+edv3oHamlmLMF0FjzP
DLatzVyrCpUuRaSgPH5gpLE4eVT9LTzII36tGVEkVNNqVP6+nz6h7NeF5vU+SUa+
0BgqXJOWAWwnEilnLXt/jdmXgU4znAP5ThxGY7dO74FrEupzoSYhk7MVss1k9SpX
EA+q11TIzt6XrcuywdXO9zAy3MGw6/QgeMEn3WFVmtHK9P4C329VHG4631Gt5KB6
xmWIdU4aCK+YC+wGSSnUTyhVLqxLCla6ccvqJnX9fEJ0NDZQC1pAwDJqr2Asu6c=
=szN2
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
