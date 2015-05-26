From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 26 May 2015 09:34:40 -0400
Message-ID: <1432647280.28905.107.camel@redhat.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Gtqb0YCKA9I3HBpDsAq1"
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbbEZNet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 09:34:49 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Gtqb0YCKA9I3HBpDsAq1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-05-17 at 08:50 +0300, Haggai Eran wrote:
> Thanks again everyone for the review comments. I've updated the patch set
> accordingly. The main changes are in the first patch to use a read-write
> semaphore instead of an SRCU, and with the reference counting of shared
> ib_cm_ids.
> Please let me know if I missed anything, or if there are other issues wit=
h
> the series.

Hi Haggai,

I know you are probably busy reworking this right now on the basis of
Jason's comments.  However, my biggest issue with this patch set right
now is not technical (well, it is, but it's only partially technical).

This is a core feature more than anything else.  Namespaces for RDMA
devices is not unique to IB or RoCE in any way.  Yet no thought has been
given to how this will work universally across all of the RDMA capable
devices (mainly I'm talking about iWARP here...I don't think this is an
issue for usNIC as if you want namespace support there, you just start
the user space app in a given namespace and you are probably 90% of the
way there since the user space application gets its own device and so
its own MAC/IP and all of the RDMA transfers are UDP, so the
application's namespace should get inherited by all the rest, but Cisco
would need to confirm that, hence why I say 90% of the way there, it
needs confirmed).

So, while you are reworking things right now, you would ideally contact
Steve Wise and/or Tatyana Nikolova and discuss the iWARP story on this.
I know there won't be a lot of overlap between IB and iWARP, but last
time you were asked you didn't even know if this setup could be extended
to iWARP.

For this next statement, I know I'm directing this to you Haggai, but
please don't take it that way.  I'm really using your patch set to make
a broader point to everyone on the list.

When I look at patches for support for a given feature, one of the
things I'm going to look at is whether or not that feature is specific
to a given hardware type, or if it's a generic feature.  If it's a
generic feature, then I'm going to want to know that the person
submitting it has designed it well.  A pre-requisite of designing a
generic feature well is that it considers all hardware types, not just
your specific hardware type.  So when you come back with the next
version of this patch set, please have an answer for how it should work
on each hardware type even if you don't have implementation patches for
each hardware type.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD


--=-Gtqb0YCKA9I3HBpDsAq1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVZHZwAAoJELgmozMOVy/d0t8P/ixPSCoqBr69vPdS/7liLaIb
c196vUK3N7c3Mht6btbzmKskJKoh7SE8s507+rjpmoHJnZ5xpqwEkIS32HRgEAqt
C9iuliruhntHr/a+Fg39842v8RC0v4w/cnJKiudKQ8FxWXYTSUsHHMlKABqFxiFh
lQtsUr72qJ3mBLvzbpIyvpDUWsXJ4o7/d4/fxNjuTPjqStZGVBh6yzEPm9Wkjdy4
Q9bibAXgZcLVbHEIc0XUZpfnMW8GO6YZ4GngPpxPXqVY9Z+egbmD+41jwyqG+l9k
1iDSYgEvZ/NkAkWCohSGg/IatmKaIPVTcZKfDo++txhWt/GUav3ueEhyZogFKgnx
Kadwm00nmIi0i0HwjM3It3GvMttMWywEDe8SiHO0B9Nmi+jq2GDZryP/Cmo6eMt/
GOTEKGsL+eBgKak8nKEkAaL7V5ZVYlVlV+Dx1yj9aWe5IhxIheJGu8IBS7MbzDXj
nKNOZMweOA/ClwYkxb709/cooSoBlUbfVekbxPZT9tzFW62YNfpkG/v5SeE6DGSX
C9LqLFzZb5WtA18Uar2MZLJp/GfexVTluXIJLYu0X/9tRbLYZyiv+sjlxIkZihGt
X1n/LIhnVytiQ5GdaK+vTrvUCVwcUZmaJYR3lhNCtbmEF4IVnJgd2q4gx1+8+/HP
AD6gvxxcVhNTKnThw4ft
=NfcI
-----END PGP SIGNATURE-----

--=-Gtqb0YCKA9I3HBpDsAq1--
