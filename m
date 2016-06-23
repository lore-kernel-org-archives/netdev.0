From: Henrik Austad <henrik@austad.us>
Subject: Re: [alsa-devel] [very-RFC 0/8] TSN driver for the kernel
Date: Thu, 23 Jun 2016 12:38:48 +0200
Message-ID: <20160623103848.GG32724@icarus.home.austad.us>
References: <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
 <20160620121838.GA5257@localhost.localdomain>
 <07283da9-f6d1-c3b1-7989-a6fce7ca0ee6@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kadn00tgSopKmJ1H"
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@linaro.org>,
	linux-media@vger.kernel.org
To: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <07283da9-f6d1-c3b1-7989-a6fce7ca0ee6@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--kadn00tgSopKmJ1H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 21, 2016 at 10:45:18AM -0700, Pierre-Louis Bossart wrote:
> On 6/20/16 5:18 AM, Richard Cochran wrote:
> >On Mon, Jun 20, 2016 at 01:08:27PM +0200, Pierre-Louis Bossart wrote:
> >>The ALSA API provides support for 'audio' timestamps (playback/capture =
rate
> >>defined by audio subsystem) and 'system' timestamps (typically linked to
> >>TSC/ART) with one option to take synchronized timestamps should the har=
dware
> >>support them.
> >
> >Thanks for the info.  I just skimmed Documentation/sound/alsa/timestampi=
ng.txt.
> >
> >That is fairly new, only since v4.1.  Are then any apps in the wild
> >that I can look at?  AFAICT, OpenAVB, gstreamer, etc, don't use the
> >new API.
>=20
> The ALSA API supports a generic .get_time_info callback, its implementati=
on
> is for now limited to a regular 'DMA' or 'link' timestamp for HDaudio - t=
he
> difference being which counters are used and how close they are to the li=
nk
> serializer. The synchronized part is still WIP but should come 'soon'

Interesting, would you mind CCing me in on those patches?

> >>The intent was that the 'audio' timestamps are translated to a shared t=
ime
> >>reference managed in userspace by gPTP, which in turn would define if
> >>(adaptive) audio sample rate conversion is needed. There is no support =
at
> >>the moment for a 'play_at' function in ALSA, only means to control a
> >>feedback loop.
> >
> >Documentation/sound/alsa/timestamping.txt says:
> >
> >  If supported in hardware, the absolute link time could also be used
> >  to define a precise start time (patches WIP)
> >
> >Two questions:
> >
> >1. Where are the patches?  (If some are coming, I would appreciate
> >   being on CC!)
> >
> >2. Can you mention specific HW that would support this?
>=20
> You can experiment with the 'dma' and 'link' timestamps today on any
> HDaudio-based device. Like I said the synchronized part has not been
> upstreamed yet (delays + dependency on ART-to-TSC conversions that made it
> in the kernel recently)

Ok, I think I see a way to hook this into timestamps from the skbuf on=20
incoming frames and a somewhat messy way on outgoing. Having time coupled=
=20
with 'avail' and 'delay' is useful, and from the looks of it, 'link'-time=
=20
is the appropriate level to add this.

I'm working on storing the time in the tsn_link struct I use, and then read=
=20
that from the avb_alsa-shim. Details are still a bit fuzzy though, but I=20
plan to do that and then see what audio-time gives me once it is up and=20
running.

Richard: is it fair to assume that if ptp4l is running and is part of a PTP=
=20
domain, ktime_get() will return PTP-adjusted time for the system? -Or do I=
=20
also need to run phc2sys in order to sync the system-time to PTP-time? Note=
=20
that this is for outgoing traffic, Rx should perhaps use the timestamp=20
in skb.

Hooking into ktime_get() instead of directly to the PTP-subsystem (if that=
=20
is even possible) makes it a lot easier to debug when running this in a VM=
=20
as it doesn't *have* to use PTP-time when I'm crashing a new kernel :)

Thanks!

--=20
Henrik Austad

--kadn00tgSopKmJ1H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldrvDgACgkQ6k5VT6v45llUQgCg9HrQkKbcPOCNa3udtOfhheRD
6SUAniWcrLovzBEtoAXePkXLHEHbduNC
=CzGG
-----END PGP SIGNATURE-----

--kadn00tgSopKmJ1H--
