From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 13 Jun 2016 00:06:39 +0200
Message-ID: <20160612220639.GE32724@icarus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <575CD93C.50006@sakamocchi.jp>
 <575CE560.9090608@sakamocchi.jp>
 <20160612083122.GB32724@icarus.home.austad.us>
 <575D3CD6.3050001@sakamocchi.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h56sxpGKRmy85csR"
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-media@vger.kernel.org
To: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36835 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933223AbcFLWGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 18:06:46 -0400
Received: by mail-lf0-f67.google.com with SMTP id j191so472123lfb.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 15:06:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <575D3CD6.3050001@sakamocchi.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--h56sxpGKRmy85csR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 12, 2016 at 07:43:34PM +0900, Takashi Sakamoto wrote:
> On Jun 12 2016 17:31, Henrik Austad wrote:
> > On Sun, Jun 12, 2016 at 01:30:24PM +0900, Takashi Sakamoto wrote:
> >> On Jun 12 2016 12:38, Takashi Sakamoto wrote:
> >>> In your patcset, there's no actual codes about how to handle any
> >>> interrupt contexts (software / hardware), how to handle packet payloa=
d,
> >>> and so on. Especially, for recent sound subsystem, the timing of
> >>> generating interrupts and which context does what works are important=
 to
> >>> reduce playback/capture latency and power consumption.
> >>>
> >>> Of source, your intention of this patchset is to show your early conc=
ept
> >>> of TSN feature. Nevertheless, both of explaination and codes are
> >>> important to the other developers who have little knowledges about TS=
N,
> >>> AVB and AES-64 such as me.
> >>
> >> Oops. Your 5th patch was skipped by alsa-project.org. I guess that size
> >> of the patch is too large to the list service. I can see it:
> >> http://marc.info/?l=3Dlinux-netdev&m=3D146568672728661&w=3D2
> >>
> >> As long as seeing the patch, packets are queueing in hrtimer callbacks
> >> every 1 seconds.
> >=20
> > Actually, the hrtimer fires every 1ms, and that part is something I hav=
e to=20
> > do something about, also because it sends of the same number of frames=
=20
> > every time, regardless of how accurate the internal timer is to the res=
t of=20
> > the network (there's no backpressure from the networking layer).
> >=20
> >> (This is a high level discussion and it's OK to ignore it for the
> >> moment. When writing packet-oriented drivers for sound subsystem, you
> >> need to pay special attention to accuracy of the number of PCM frames
> >> transferred currently, and granularity of the number of PCM frames
> >> transferred by one operation. In this case, snd_avb_hw,
> >> snd_avb_pcm_pointer(), tsn_buffer_write_net() and tsn_buffer_read_net()
> >> are involved in this discussion. You can see ALSA developers' struggle
> >> in USB audio device class drivers and (of cource) IEC 61883-1/6 driver=
s.)
> >=20
> > Ah, good point. Any particular parts of the USB-subsystem I should star=
t=20
> > looking at?
>=20
> I don't think it's a beter way for you to study USB Audio Device Class
> driver unless you're interested in ALSA or USB subsystem.
>=20
> (But for your information, snd-usb-audio is in sound/usb/* of Linux
> kernel. IEC 61883-1/6 driver is in sound/firewire/*.)

Ok, thanks, I'll definately be looking at the firewire bit

> We need different strategy to achieve it on different transmission backen=
d.
>=20
> > Knowing where to start looking is a tremendous help
>=20
> It's not well-documented, and not well-generalized for packet-oriented
> drivers. Most of developers who have enough knowledge about it work for
> DMA-oriented drivers in mobile platforms and have little interests in
> packet-oriented drivers. You need to find your own way.
>=20
> Currently I have few advices to you, because I'm also on the way for
> drivers to process IEC 61883-1/6 packets on IEEE 1394 bus with enough
> accuracy and granularity. The paper I introduced is for the way (but not
> mature).
>=20
> I wish you get more helps from the other developers. Your work is more
> significant to Linux system, than mine.
>=20
> (And I hope your future work get no ignorance and no unreasonable
> hostility from coarse users.)

Ah well, I have asbestos-underwear so that should be fine :)

Thanks for the pointers, I really appreciate them!



--=20
Henrik Austad

--h56sxpGKRmy85csR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldd3O8ACgkQ6k5VT6v45ln6ywCfRfOTsKraUa7CiP1H4mzMckMK
MjoAnjWImNmwqPpO4bIqb512NkaeIUyT
=QoZ6
-----END PGP SIGNATURE-----

--h56sxpGKRmy85csR--
