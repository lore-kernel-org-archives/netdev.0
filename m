From: Karsten Keil <keil@b1-systems.de>
Subject: Re: [PATCH 1/8] isdn/gigaset: ratelimit CAPI message dumps
Date: Sat, 28 Apr 2012 11:29:32 +0200
Message-ID: <4F9BB87C.4050103@b1-systems.de>
References: <20120425-patch-gigaset-00.tilman@imap.cc> <20120425-patch-gigaset-01.tilman@imap.cc> <4F98EDB1.5090702@b1-systems.de> <4F9A7510.5010808@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9A7510.5010808@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 27.04.2012 12:29, schrieb Tilman Schmidt:
> Am 26.04.2012 08:39, schrieb Karsten Keil:
>> Am 26.04.2012 01:02, schrieb Tilman Schmidt:
>>> Introduce a global ratelimit for CAPI message dumps to protect
>>>  against possible log flood. Drop the ratelimit for ignored=20
>>> messages which is now covered by the global one.
>>=20
>> Hmm, I think the only CAPI messages which would need a ratelimit=20
>> are related to the DATA_B3 messages. If you need CAPI debug=20
>> messages in most cases you do not need all of the DATA_B3, but=20
>> you do not want to miss any other message related to the call=20
>> control. With a general rate limit you do not have the control,=20
>> which messages are logged and which are not.
>=20
> The ratelimit introduced by this patch only applies to messages=20
> other than DATA_B3. Logging DATA_B3 messages is not done via=20
> dump_cmsg().
>=20

Thanks for the clarification, forget about my objection.
I ack this patch now.

> I'd like to ratelimit specifically non-DATA_B3 messages because I=20
> saw a (possibly buggy) CAPI application flooding the log with=20
> FACILITY messages. Equally important, I'd like to make the=20
> ratelimit in do_nothing() / do_unsupported() bursty because I had
> a case where I needed to see several ignored/unhandled CAPI
> messages in quick succession. So this patch is killing two birds
> with one stone for me.
>=20
> The burst limit of 20 messages in 20 seconds is chosen to allow a=20
> complete call setup sequence to be logged, while limiting to one=20
> message per second in the long run.
>=20
>> And here maybe some cases, when even the DATA_B3 are important=20
>> (e.g. searching bugs in flow control), so I would make it still=20
>> conditional to allow to print all messages.
>=20
> DATA_B3 dumps produce an enormous amount of log data and are=20
> therefore controlled separately by the DEBUG_MCMD flag. Someone
> who enables that should know what she or he does. But if you need
> them, you need them all. A ratelimit doesn't make sense there in
> my experience.
>=20
>> And I'm not sure, if this is really something for stable.
>=20
> It's pretty simple and localized, a net simplification, and only=20
> affects generation of debugging messages, so I think it's safe.
> But if you see a problem there I can drop the "CC: stable" line.
>=20

I let the decision about it to you and the stable maintainers.

- --=20
Karsten Keil
Linux Kernel Development
Tel: +49 175 7249132
Mail: keil@b1-systems.de

B1 Systems GmbH
Osterfeldstra=DFe 7 / 85088 Vohburg / http://www.b1-systems.de
GF: Ralph Dehner / Unternehmenssitz: Vohburg / AG: Ingolstadt,HRB 3537
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk+buHwACgkQo5VVC52CNcRoygCfWwPlWZ+A48OwEkr/MtK6PeNG
0UEAnipdxPSZDKa4s99LlGYwvggWIIAJ
=3DCLr6
-----END PGP SIGNATURE-----
