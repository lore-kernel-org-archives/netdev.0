From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Sun, 12 Jun 2016 19:43:34 +0900
Message-ID: <575D3CD6.3050001@sakamocchi.jp>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <575CD93C.50006@sakamocchi.jp> <575CE560.9090608@sakamocchi.jp>
 <20160612083122.GB32724@icarus.home.austad.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="UsR84E3dGIn60IX3V7DNPtulHtaLdK7uD"
Cc: netdev@vger.kernel.org, linux-media@vger.kernel.org
To: Henrik Austad <henrik@austad.us>, alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-proxy002.phy.lolipop.jp ([157.7.104.43]:45102 "EHLO
	smtp-proxy002.phy.lolipop.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750924AbcFLKnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 06:43:42 -0400
In-Reply-To: <20160612083122.GB32724@icarus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UsR84E3dGIn60IX3V7DNPtulHtaLdK7uD
Content-Type: multipart/mixed; boundary="K0b4NFlup2Hr3Mf9McNagelra53C3B9tq"
From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
To: Henrik Austad <henrik@austad.us>, alsa-devel@alsa-project.org
Cc: netdev@vger.kernel.org, linux-media@vger.kernel.org
Message-ID: <575D3CD6.3050001@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <575CD93C.50006@sakamocchi.jp> <575CE560.9090608@sakamocchi.jp>
 <20160612083122.GB32724@icarus.home.austad.us>
In-Reply-To: <20160612083122.GB32724@icarus.home.austad.us>

--K0b4NFlup2Hr3Mf9McNagelra53C3B9tq
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On Jun 12 2016 17:31, Henrik Austad wrote:
> On Sun, Jun 12, 2016 at 01:30:24PM +0900, Takashi Sakamoto wrote:
>> On Jun 12 2016 12:38, Takashi Sakamoto wrote:
>>> In your patcset, there's no actual codes about how to handle any
>>> interrupt contexts (software / hardware), how to handle packet payloa=
d,
>>> and so on. Especially, for recent sound subsystem, the timing of
>>> generating interrupts and which context does what works are important=
 to
>>> reduce playback/capture latency and power consumption.
>>>
>>> Of source, your intention of this patchset is to show your early conc=
ept
>>> of TSN feature. Nevertheless, both of explaination and codes are
>>> important to the other developers who have little knowledges about TS=
N,
>>> AVB and AES-64 such as me.
>>
>> Oops. Your 5th patch was skipped by alsa-project.org. I guess that siz=
e
>> of the patch is too large to the list service. I can see it:
>> http://marc.info/?l=3Dlinux-netdev&m=3D146568672728661&w=3D2
>>
>> As long as seeing the patch, packets are queueing in hrtimer callbacks=

>> every 1 seconds.
>=20
> Actually, the hrtimer fires every 1ms, and that part is something I hav=
e to=20
> do something about, also because it sends of the same number of frames =

> every time, regardless of how accurate the internal timer is to the res=
t of=20
> the network (there's no backpressure from the networking layer).
>=20
>> (This is a high level discussion and it's OK to ignore it for the
>> moment. When writing packet-oriented drivers for sound subsystem, you
>> need to pay special attention to accuracy of the number of PCM frames
>> transferred currently, and granularity of the number of PCM frames
>> transferred by one operation. In this case, snd_avb_hw,
>> snd_avb_pcm_pointer(), tsn_buffer_write_net() and tsn_buffer_read_net(=
)
>> are involved in this discussion. You can see ALSA developers' struggle=

>> in USB audio device class drivers and (of cource) IEC 61883-1/6 driver=
s.)
>=20
> Ah, good point. Any particular parts of the USB-subsystem I should star=
t=20
> looking at?

I don't think it's a beter way for you to study USB Audio Device Class
driver unless you're interested in ALSA or USB subsystem.

(But for your information, snd-usb-audio is in sound/usb/* of Linux
kernel. IEC 61883-1/6 driver is in sound/firewire/*.)

We need different strategy to achieve it on different transmission backen=
d.

> Knowing where to start looking is a tremendous help

It's not well-documented, and not well-generalized for packet-oriented
drivers. Most of developers who have enough knowledge about it work for
DMA-oriented drivers in mobile platforms and have little interests in
packet-oriented drivers. You need to find your own way.

Currently I have few advices to you, because I'm also on the way for
drivers to process IEC 61883-1/6 packets on IEEE 1394 bus with enough
accuracy and granularity. The paper I introduced is for the way (but not
mature).

I wish you get more helps from the other developers. Your work is more
significant to Linux system, than mine.

(And I hope your future work get no ignorance and no unreasonable
hostility from coarse users.)


Regards

Takashi Sakamoto


--K0b4NFlup2Hr3Mf9McNagelra53C3B9tq--

--UsR84E3dGIn60IX3V7DNPtulHtaLdK7uD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXXTzWAAoJELWlhsfWb9NBiy0P/0l3ILGCvxaE50WGVEFUFJdJ
tOHBl9Nw2T+VZNxpspbRMZ/03qx7VMCfszn4CzTYuA3nN1h5KxPDJo5/Fq6/v6tA
eneP2c623wPmzUAPhGE8ThAgmJGUtmq82JYVAWsjTYm7m5LeOhVjckyw9P8uy1od
DJeqO5oth2HGWb86JaVSMOpVqY+JVwb9qT04yOZ+JRa2VAgsgs/YdhYBHi7RS45O
vfvNuR2EAvqNQwY4woDefdQJoHA0hlpx0NiCrJuRQebHsXSeTsCloB5bL+xbfS1V
dFtf66P2BUMQ7u78xQ1Q/GDeYN23s6VhS5KcuRZ5ExC2Mp913Le55ovxOlZflg14
3xJHt8PCXZp/Xbn0X/46mrSn0kErib6B10ublL6Ocr8rO/DxoHip4MGtrOl66LDa
qy4DFxniE69b8wPxbf6h8mc7zzXYlYy0vIjsBqR37AvvHZdy2FiyAUO7Al7U0qwl
NMuglNCDObkTnNF8Zlmyy9gZyMwNkTNguV8YM7Kx9B6H0OzWmqTJXTcJdEf7p0xa
5i8tOMWoFhNnk6zM0T4tWbSZ84OQx1Y3ER7pDZAZQRnKTun0AQO7cdHqS5jU+CyC
iuMdo0+83vW8sCc/Bp8YEdyc9crDSlUeMVOPldn90zHyz/69i39FWb4jdczrbDnb
/I6fs/pYTFIfISTTs6pr
=zn4h
-----END PGP SIGNATURE-----

--UsR84E3dGIn60IX3V7DNPtulHtaLdK7uD--
