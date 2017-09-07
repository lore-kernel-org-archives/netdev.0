From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 17:27:51 +0200
Message-ID: <20170907152751.GA9064@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170907053411.GA6580@sisyphus.home.austad.us>
 <20170907124018.deinzo3c4ice3q7n@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:37921 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754628AbdIGP2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 11:28:17 -0400
Received: by mail-lf0-f67.google.com with SMTP id m199so4542343lfe.5
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 08:28:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170907124018.deinzo3c4ice3q7n@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 07, 2017 at 02:40:18PM +0200, Richard Cochran wrote:
> On Thu, Sep 07, 2017 at 07:34:11AM +0200, Henrik Austad wrote:
> > Also, does this mean that when you create the qdisc, you have locked th=
e=20
> > bandwidth for the scheduler? Meaning, if I later want to add another=20
> > stream that requires more bandwidth, I have to close all active streams=
,=20
> > reconfigure the qdisc and then restart?
>=20
> No, just allocate enough bandwidth to accomodate all of the expected
> streams.  The streams can start and stop at will.

Sure, that'll work.

And if you want to this driver to act as a bridge, how do you accomodate=20
change in network requirements? (i.e. how does this work with switchdev?)
- Or am I overthinking this?

> > So my understanding of all of this is that you configure the *total*=20
> > bandwith for each class when you load the qdisc and then let userspace=
=20
> > handle the rest. Is this correct?
>=20
> Nothing wrong with that.

Didn't mean to say it was wrong, just making sure I've understood the=20
concept.

> > In my view, it would be nice if the qdisc had some notion about streams=
 so=20
> > that you could create a stream, feed frames to it and let the driver pa=
ce=20
> > them out. (The fewer you queue, the shorter the delay). This will also=
=20
> > allow you to enforce per-stream bandwidth restrictions. I don't see how=
 you=20
> > can do this here unless you want to do this in userspace.
> >=20
> > Do you have any plans for adding support for multiplexing streams? If y=
ou=20
> > have multiple streams, how do you enforce that one stream does not eat =
into=20
> > the bandwidth of another stream? AFAIK, this is something the network m=
ust=20
> > enforce, but I see no option of doing som here.
>=20
> Please, lets keep this simple.=20

Simple is always good

> Today we have exactly zero user space
> applications using this kind of bandwidth reservation.  The case of
> wanting the kernel to police individual stream usage does not exist,
> and probably never will.

That we have *zero* userspace applications today is probably related to the=
=20
fact that we have exacatly *zero* drivers in the kernel that talks TSN :)

To rephrase a bit, what I'm worried about:

If you have more than 1 application in userspace that wants to send data=20
using this scheduler, how do you ensure fair transmission of frames? (both=
=20
how much bandwidth they use, but also ordering of frames from each=20
application) Do you expect all of this to be handled in userspace?

> For serious TSN use cases, the bandwidth needed by each system and
> indeed the entire network will be engineered, and we can reasonably
> expect applications to cooperate in this regard.

yes.. that'll happen ;)

> Thanks,
> Richard

Don't get me wrong, I think it is great that others are working on this!
I'm just trying to fully understand the thought that have gone into this=20
and how it is inteded to be used.

I'll get busy testing the code and wrapping my head around the different=20
parameters.

--=20
Henrik Austad

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmxZXcACgkQ6k5VT6v45lleJwCcDtsn5IoBqUq/5Khopv/JB4VH
UoYAn3xHPhJKT+4wVfH0/rh6qQ928Lxb
=+jK8
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
