From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Sun, 12 Jun 2016 18:14:49 +0900
Message-ID: <575D2809.9020903@sakamocchi.jp>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <575CD93C.50006@sakamocchi.jp> <20160612082852.GA32724@icarus.home.austad.us>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4237115519634769012=="
Cc: netdev@vger.kernel.org, alsa-devel@alsa-project.org,
 linux-media@vger.kernel.org, alsa-devel@vger.kernel.org, henrk@austad.us
To: Henrik Austad <henrik@austad.us>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20160612082852.GA32724@icarus.home.austad.us>
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

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============4237115519634769012==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vH47jvMUfF2lIBf46CLLdkRFuNv9P0Gu6"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vH47jvMUfF2lIBf46CLLdkRFuNv9P0Gu6
Content-Type: multipart/mixed; boundary="6lag9WIGPbQbhbEDSbiR6XOMgx44sk23J"
From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
To: Henrik Austad <henrik@austad.us>
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org, henrk@austad.us,
 alsa-devel@vger.kernel.org, linux-media@vger.kernel.org
Message-ID: <575D2809.9020903@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <575CD93C.50006@sakamocchi.jp> <20160612082852.GA32724@icarus.home.austad.us>
In-Reply-To: <20160612082852.GA32724@icarus.home.austad.us>

--6lag9WIGPbQbhbEDSbiR6XOMgx44sk23J
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On Jun 12 2016 17:28, Henrik Austad wrote:
> On Sun, Jun 12, 2016 at 12:38:36PM +0900, Takashi Sakamoto wrote:
>> I'm one of maintainers for ALSA firewire stack, which handles IEC
>> 61883-1/6 and vendor-unique packets on IEEE 1394 bus for consumer
>> recording equipments.
>> (I'm not in MAINTAINERS because I'm a shy boy.)
>>
>> IEC 61883-6 describes that one packet can multiplex several types of
>> data in its data channels; i.e. Multi Bit Linear Audio data (PCM
>> samples), One Bit Audio Data (DSD), MIDI messages and so on.
>=20
> Hmm, that I did not know, not sure how that applies to AVB, but definat=
ely=20
> something I have to look into.

For your information, I describe more about it.

You can see pre-standardized specification for IEC 61883-6 in website of
1394 Trade Association. Let's look for 'Audio and Music Data
Transmission Protocol 2.3 (October 13, 2010, 1394TA)'
http://1394ta.org/specifications/

In 'clause 12. AM824 SEQUENCE ADAPTATION LAYERS', you can see that one
data block includes several types of data.


But I can imagine that joint group for AVB loosely refers to IEC
61883-6. In this case, AVB specification might describe one data block
transfers one type of data, to drop unreasonable complexities.

>> If you handles packet payload in 'struct snd_pcm_ops.copy', a process
>> context of an ALSA PCM applications performs the work. Thus, no chance=
s
>> to multiplex data with the other types.
>=20
> The driver is not adhering fully to any standards right now, the amount=
 of=20
> detail is quite high - but I'm slowly improving as I go through the=20
> standards. Getting on top of all the standards and all the different=20
> subsystems are definately a work in progress (it's a lot to digest!)

In my taste, the driver is not necessarily compliant to any standards.
It's enough just to work its task, without bad side-effects to Linux
system. Based on this concept, current ALSA firewire stack just support
PCM frames and MIDI messages.

Here, I tell you that actual devices tend not to be compliant to any
standards and lost inter-operability.

(Especially, most of audio and music units on IEEE 1394 bus ignores some
of items in standards. In short, they already lost inter-operability.)

So here, we just consider about what actual devices do, instead of
following any standards.


Regards

Takashi Sakamoto


--6lag9WIGPbQbhbEDSbiR6XOMgx44sk23J--

--vH47jvMUfF2lIBf46CLLdkRFuNv9P0Gu6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXXSgPAAoJELWlhsfWb9NBot4P/RqHqRt+ZHC9pmoVKfbDM+Gg
Uu5my0lQuMnWg2FPuVL6l450S/jsITLV5ERMEVU4vYhTKfit18dxhd+Ur7R7VEaA
Z+4NjDn0pxJvOCENss1pvRRWFTxbR70g+k0Zzxh2e/bfAvi1tsUvTKPCGfoU6Mvb
msM04PfZN/+ZFLn8FO8WQpmNIbWaMfbvLwg0TMcUSb93t68BS0dBm1pYX3doBt7T
5KUqufhgOfZB+o2aFikzXR9J47yZZeMs+2P9DRO6l4Czi3LQur4VxriYsMQpF7oL
LfG1oZM/jvquGstGUsND0eQHPqDAzlV8wbLya76ieFOW937rMHoMnL1AUFU/8dlP
zBhEnCbOw/eQtiPLhPKgsky/SfK+/dStx5uSs3cRkeh5VmZkkZJV5gxjlxRooAwK
ziWvMNdQCz+uHujQB40wCPh1IIwXBzQ61wLtn8X1iMfeOYrvVcyUayBxlJA1Gjm+
36XpjFhM7ZiO1E2iifid9y6qMmNQ5HR5iQVQeQ3NvWgNW32/eYUMvuVI32OIJr2X
6SEWvk+g90wGYlsRNyeJgcuYovEsgysSF0WANGN/vewZr5Wq1/7O+1s9uEBGrlXB
j7I+0CaGo+PyAJGhpBmY/jGVrCQqPIbHXkqfYL7xKKqBu+2u1RiO5dZN89MlSFLx
u7jhCb2BhyacGkoDVvlU
=MRQF
-----END PGP SIGNATURE-----

--vH47jvMUfF2lIBf46CLLdkRFuNv9P0Gu6--

--===============4237115519634769012==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============4237115519634769012==--
