From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 20 Jun 2016 13:49:24 +0200
Message-ID: <20160620114924.GA8971@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1943340164621468105=="
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
 Richard Cochran <richardcochran@gmail.com>, linux-kernel@vger.kernel.org,
 Takashi Sakamoto <o-takashi@sakamocchi.jp>, Arnd Bergmann <arnd@linaro.org>,
 linux-media@vger.kernel.org
To: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org


--===============1943340164621468105==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Content-Disposition: inline


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 20, 2016 at 01:08:27PM +0200, Pierre-Louis Bossart wrote:
>=20
> >Presentation time is either set by
> >a) Local sound card performing capture (in which case it will be 'capture
> >   time')
> >b) Local media application sending a stream accross the network
> >   (time when the sample should be played out remotely)
> >c) Remote media application streaming data *to* host, in which case it w=
ill
> >   be local presentation time on local  soundcard
> >
> >>This value is dominant to the number of events included in an IEC 61883=
-1
> >>packet. If this TSN subsystem decides it, most of these items don't need
> >>to be in ALSA.
> >
> >Not sure if I understand this correctly.
> >
> >TSN should have a reference to the timing-domain of each *local*
> >sound-device (for local capture or playback) as well as the shared
> >time-reference provided by gPTP.
> >
> >Unless an End-station acts as GrandMaster for the gPTP-domain, time set
> >forth by gPTP is inmutable and cannot be adjusted. It follows that the
> >sample-frequency of the local audio-devices must be adjusted, or the
> >audio-streams to/from said devices must be resampled.
>=20
> The ALSA API provides support for 'audio' timestamps
> (playback/capture rate defined by audio subsystem) and 'system'
> timestamps (typically linked to TSC/ART) with one option to take
> synchronized timestamps should the hardware support them.

Ok, this sounds promising, and very much in line with what AVB would need.

> The intent was that the 'audio' timestamps are translated to a
> shared time reference managed in userspace by gPTP, which in turn
> would define if (adaptive) audio sample rate conversion is needed.
> There is no support at the moment for a 'play_at' function in ALSA,
> only means to control a feedback loop.

Ok, I understand that the 'play_at' is difficult to obtain, but it sounds=
=20
like it is doable to achieve something useful.

Looks like I will be looking into what to put in the .trigger-handler in=20
the ALSA shim and experimenting with this to see how it make sense to=20
connect it from the TSN-stream.

Thanks!

--=20
Henrik Austad

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldn2EQACgkQ6k5VT6v45lmUdgCg719YnKINnt32mXLLlC3WGGd2
CZAAoJNPHDA3nfk8NumL7HmqCipmeIQl
=gNYw
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--

--===============1943340164621468105==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1943340164621468105==--
