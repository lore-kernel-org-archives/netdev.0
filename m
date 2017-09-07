From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 18:18:38 +0200
Message-ID: <20170907161838.GB9064@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170907053411.GA6580@sisyphus.home.austad.us>
 <20170907124018.deinzo3c4ice3q7n@localhost>
 <20170907152751.GA9064@sisyphus.home.austad.us>
 <20170907155315.5gqy5e4susl25wa2@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="tjCHc7DPkfUGtrlw"
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36987 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932303AbdIGQTE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 12:19:04 -0400
Received: by mail-lf0-f47.google.com with SMTP id 80so282912lfy.4
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 09:19:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170907155315.5gqy5e4susl25wa2@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tjCHc7DPkfUGtrlw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 07, 2017 at 05:53:15PM +0200, Richard Cochran wrote:
> On Thu, Sep 07, 2017 at 05:27:51PM +0200, Henrik Austad wrote:
> > On Thu, Sep 07, 2017 at 02:40:18PM +0200, Richard Cochran wrote:
> > And if you want to this driver to act as a bridge, how do you accomodat=
e=20
> > change in network requirements? (i.e. how does this work with switchdev=
?)
>=20
> To my understanding, this Qdisc idea provides QoS for the host's
> transmitted traffic, and nothing more.

Ok, then we're on the same page.

> > - Or am I overthinking this?
>=20
> Being able to configure the external ports of a switchdev is probably
> a nice feature, but that is another story.  (But maybe I misunderstood
> the authors' intent!)

ok, chalk that one up for later perhaps

> > If you have more than 1 application in userspace that wants to send dat=
a=20
> > using this scheduler, how do you ensure fair transmission of frames? (b=
oth=20
> > how much bandwidth they use,
>=20
> There are many ways to handle this, and we shouldn't put any of that
> policy into the kernel.  For example, there might be a monolithic
> application with configurable threads, or an allocation server that
> grants bandwidth to applications via IPC, or a multiplexing stream
> server like jack, pulse, etc, and so on...

true

> > but also ordering of frames from each application)
>=20
> Not sure what you mean by this.

Fair enough, I'm not that good at making myself clear :)

Let's see if I can make a better attempt:

If you have 2 separate applications that have their own streams going to=20
different endpoints - but both are in the same class, then they will=20
share the qdisc bandwidth.

So application=20
- A sends frame A1, A2, A3, .. An
- B sends B1, B2, .. Bn

What I was trying to describe was: if application A send 2 frames, and B=20
sends 2 frames at the same time, then you would hope that the order would=
=20
be A1, B1, A2, B2, and not A1, A2, B1, B2.

None of this would be a problem if you expect a *single* user, like the=20
allocation server you described above. Again, I think this is just me=20
overthinking the problem right now :)

> > Do you expect all of this to be handled in userspace?
>=20
> Yes, I do.

ok, fair enough

Thanks for answering my questions!

--=20
Henrik Austad

--tjCHc7DPkfUGtrlw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmxcV4ACgkQ6k5VT6v45lkOEgCeLoqZUP662YojEhuwJ948psTi
lKUAn2S2kuRs6QAtIT+m4NaVqMVX7uUz
=4Wr5
-----END PGP SIGNATURE-----

--tjCHc7DPkfUGtrlw--
