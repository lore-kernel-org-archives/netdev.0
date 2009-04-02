From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 08:50:43 -0400
Message-ID: <49D4B4A3.5070008@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9185F14DE1ADD1C335B6DE94"
Cc: Avi Kivity <avi@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:45017 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbZDBMsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 08:48:32 -0400
In-Reply-To: <200904022243.21088.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9185F14DE1ADD1C335B6DE94
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

Rusty Russell wrote:
> On Thursday 02 April 2009 21:36:07 Gregory Haskins wrote:
>  =20
>> You do not need to know when the packet is copied (which I currently
>> do).  You only need it for zero-copy (of which I would like to support=
,
>> but as I understand it there are problems with the reliability of prop=
er
>> callback (i.e. skb->destructor).
>>    =20
>
> But if you have a UP guest,

I assume you mean UP host ;)

>  there will *never* be another packet in the queue
> at this point, since it wasn't running.
>  =20
Yep, and I'll be the first to admit that my design only looks forward.=20
Its for high speed links and multi-core cpus, etc.  If you have a
uniprocessor host, the throughput would likely start to suffer with my
current strategy.  You could probably reclaim some of that throughput
(but trading latency) by doing as you are suggesting with the deferred
initial signalling.  However, it is still a tradeoff to account for the
lower-end rig.  I could certainly put a heuristic/timer on the
guest->host to mitigate this as well, but this is not my target use case
anyway so I am not sure it is worth it.


> As Avi said, you can do the processing in another thread and go back to=
 the
> guest; lguest pre-virtio did a hacky "weak" wakeup to ensure the guest =
ran
> again before the thread did for exactly this kind of reason.
>
> While Avi's point about a "powerful enough userspace API" is probably v=
alid,
> I don't think it's going to happen.  It's almost certainly less code to=
 put a
> virtio_net server in the kernel, than it is to create such a powerful
> interface (see vringfd & tap).  And that interface would have one user =
in
> practice.
>
> So, let's roll out a kernel virtio_net server.  Anyone?
>  =20
Hmm..well I was hoping to be able to work with you guys to make my
proposal fit this role.  If there is no interest in that, I hope that my
infrastructure itself may still be considered for merging (in *some*
tree, not -kvm per se) as I would prefer to not maintain it out of tree
if it can be avoided.  I think people will find that the new logic
touches very few existing kernel lines at all, and can be completely
disabled with config options so it should be relatively inconsequential
to those that do not care.

-Greg



--------------enig9185F14DE1ADD1C335B6DE94
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEUEARECAAYFAknUtKMACgkQlOSOBdgZUxkpgQCfW0N3n4OMfZpkQYjwCnD5XTo+
iloAl1blBgGiJv0/dx6Elp2ImW2Y0+0=
=6JhY
-----END PGP SIGNATURE-----

--------------enig9185F14DE1ADD1C335B6DE94--
