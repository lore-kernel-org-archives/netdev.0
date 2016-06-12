From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Sun, 12 Jun 2016 10:31:22 +0200
Message-ID: <20160612083122.GB32724@icarus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <575CD93C.50006@sakamocchi.jp>
 <575CE560.9090608@sakamocchi.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aM3YZ0Iwxop3KEKx"
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	henrk@austad.us
To: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36026 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbcFLIb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 04:31:26 -0400
Received: by mail-lf0-f65.google.com with SMTP id h68so8959731lfh.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 01:31:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <575CE560.9090608@sakamocchi.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--aM3YZ0Iwxop3KEKx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 12, 2016 at 01:30:24PM +0900, Takashi Sakamoto wrote:
> On Jun 12 2016 12:38, Takashi Sakamoto wrote:
> > In your patcset, there's no actual codes about how to handle any
> > interrupt contexts (software / hardware), how to handle packet payload,
> > and so on. Especially, for recent sound subsystem, the timing of
> > generating interrupts and which context does what works are important to
> > reduce playback/capture latency and power consumption.
> >=20
> > Of source, your intention of this patchset is to show your early concept
> > of TSN feature. Nevertheless, both of explaination and codes are
> > important to the other developers who have little knowledges about TSN,
> > AVB and AES-64 such as me.
>=20
> Oops. Your 5th patch was skipped by alsa-project.org. I guess that size
> of the patch is too large to the list service. I can see it:
> http://marc.info/?l=3Dlinux-netdev&m=3D146568672728661&w=3D2
>=20
> As long as seeing the patch, packets are queueing in hrtimer callbacks
> every 1 seconds.

Actually, the hrtimer fires every 1ms, and that part is something I have to=
=20
do something about, also because it sends of the same number of frames=20
every time, regardless of how accurate the internal timer is to the rest of=
=20
the network (there's no backpressure from the networking layer).

> (This is a high level discussion and it's OK to ignore it for the
> moment. When writing packet-oriented drivers for sound subsystem, you
> need to pay special attention to accuracy of the number of PCM frames
> transferred currently, and granularity of the number of PCM frames
> transferred by one operation. In this case, snd_avb_hw,
> snd_avb_pcm_pointer(), tsn_buffer_write_net() and tsn_buffer_read_net()
> are involved in this discussion. You can see ALSA developers' struggle
> in USB audio device class drivers and (of cource) IEC 61883-1/6 drivers.)

Ah, good point. Any particular parts of the USB-subsystem I should start=20
looking at? Knowing where to start looking is a tremendous help

Thanks for the feedback!

--=20
Henrik Austad

--aM3YZ0Iwxop3KEKx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlddHdoACgkQ6k5VT6v45llG3wCgqAG/ur2mhrFeG832BSvdd2Gq
K4MAnjoJZoCKvUGX8+im5CilGy6kQ8of
=UjHz
-----END PGP SIGNATURE-----

--aM3YZ0Iwxop3KEKx--
