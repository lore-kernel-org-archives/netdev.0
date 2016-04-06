From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: AF_VSOCK status
Date: Wed, 6 Apr 2016 10:26:09 +0100
Message-ID: <20160406092609.GA17538@stefanha-x1.localdomain>
References: <5703B0F3.7050700@nagafix.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Cc: netdev@vger.kernel.org
To: Antoine Martin <antoine@nagafix.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932305AbcDFJ0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 05:26:13 -0400
Content-Disposition: inline
In-Reply-To: <5703B0F3.7050700@nagafix.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 05, 2016 at 07:34:59PM +0700, Antoine Martin wrote:
> Forgive me if these questions are obvious, I am not a kernel developer.
> From what I am reading here:
> http://lists.linuxfoundation.org/pipermail/virtualization/2015-December/030935.html
> The code has been removed from mainline, is it queued for 4.6? If not,
> when are you planning on re-submitting it?

The patches are on the list (latest version sent last week):
http://comments.gmane.org/gmane.linux.kernel.virtualization/27455

They are only "Request For Comments" because the VIRTIO specification
changes have not been approved yet.  Once the spec is approved then the
patches can be seriously considered for merging.

There will definitely be a v6 with Claudio Imbrenda's locking fixes.

> We now have a vsock transport merged into xpra, which works very well
> with the kernel and qemu versions found here:
> http://qemu-project.org/Features/VirtioVsock
> Congratulations on making this easy to use!
> Is the upcoming revised interface likely to cause incompatibilities with
> existing binaries?

Userspace applications should not notice a difference.

> It seems impossible for the host to connect to a guest: the guest has to
> initiate the connection. Is this a feature / known limitation or am I
> missing something? For some of our use cases, it would be more practical
> to connect in the other direction.

host->guest connections have always been allowed.  I just checked that
it works with the latest code in my repo:

  guest# nc-vsock -l 1234
  host# nc-vsock 3 1234

> In terms of raw performance, I am getting about 10Gbps on an Intel
> Skylake i7 (the data stream arrives from the OS socket recv syscall
> split into 256KB chunks), that's good but not much faster than
> virtio-net and since the packets are avoiding all sorts of OS layer
> overheads I was hoping to get a little bit closer to the ~200Gbps memory
> bandwidth that this CPU+RAM are capable of. Am I dreaming or just doing
> it wrong?

virtio-vsock is not yet optimized but the priority is not to make
something faster than virtio-net.  virtio-vsock is not for applications
who are trying to squeeze out every last drop of performance.  Instead
the goal is to have a transport for guest<->hypervisor services that
need to be zero-configuration.

> How hard would it be to introduce a virtio mmap-like transport of some
> sort so that the guest and host could share some memory region?
> I assume this would give us the best possible performance when
> transferring large amounts of data? (we already have a local mmap
> transport we could adapt)

Shared memory is beyond the scope of virtio-vsock and it's unlikely to
be added.  There are a few existing ways to achieve that without
involving virtio-vsock: vhost-user or ivshmem.

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXBNYxAAoJEJykq7OBq3PIPW0H/RHPu0lQpWRLoutVJKWIMSIs
XYNgK5+akY6S2Wdi3Wh6VOq1ulfSxtzuVZLvBJpzd7HFeNWsaHHm/wz/GyOw2nvs
J86FTlmyrw915m3+yRcnIbFJ1eZQMt1LYQANGwdYsj/+3qJ4NsUkRl59rRFgZDQi
W1H/sRH4cPAQWA2oRWbRStLj1csldF6flDzMxqhN+y4mvzK6nSXaDE2UqyLo7yfQ
/RW5OfcG8WaZIgu5ztyJyYr4tciDlRWuEASMEsHv1GSsS39r3SRaIhsQJgp1B3pN
A6uTet1Pnlor/Sc8Rc6TlJBGwvIh4SSTdlOn+71TJ+kgfCcx+yxWiXecNwlS/cA=
=gpKX
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--
