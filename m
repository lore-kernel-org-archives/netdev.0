From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: AF_VSOCK unimplemented sockopts
Date: Thu, 3 Aug 2017 11:41:16 +0100
Message-ID: <20170803104116.GA22685@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Cc: netdev@vger.kernel.org
To: Jorgen Hansen <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48156 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751250AbdHCKlY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 06:41:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jorgen,
There are 3 sockopts defined in include/uapi/linux/vm_sockets.h that are
currently not implemented in net/vmw_vsock/af_vsock.c:

 * SO_VM_SOCKETS_PEER_HOST_VM_ID
 * SO_VM_SOCKETS_TRUSTED
 * SO_VM_SOCKETS_NONBLOCK_TXRX

I noticed this because SO_VM_SOCKETS_TRUSTED is interesting for
virtio-vsock.  Services listening on AF_VSOCK inside the guest may not
want arbitrary unprivileged host processes to connect.  Instead of
inventing a new solution I wanted to look into SO_VM_SOCKETS_TRUSTED but
found it is not implemented in linux.git.

What is the status of these sockopts?

Thanks,
Stefan

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZgv3MAAoJEJykq7OBq3PId4IIAIYUC865A0dgt2KYs/eHHAVs
/Uq+HziQ8AqIG2YDu01oMx+448rTpdhkf/j42Px0eb5FORBVFgymIz88yHAWNR/m
ZcX7V1FP0JDiXTbMjk9N/5E+BNAYExlh9H6WHFV0MGZiVeVGfM662g+vuQ/hZu8m
EcUj3UelmXvgA6BvB+9fO03QvJsARSJVJeNjcazRTcRMfPuTIEWzEaTQKs48qeFM
iAdpxdfChaXQOvBj9tipv4liN0yc28ixn8csjqejCpHbFHZIKeXVrqJ34VVidFmF
zRweKX09NdOFGKXtXWERy3B0BEQGFkpcnDG8t0TBzUJ3sQ5jIBXDax3e5XOI4GY=
=I8QB
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--
