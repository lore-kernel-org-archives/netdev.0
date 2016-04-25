From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH RFC] b43: stop hardcoding LED behavior
Date: Mon, 25 Apr 2016 20:32:05 +0200
Message-ID: <20160425203205.46f6774b@wiggum>
References: <1461570051-3950-1-git-send-email-dev@lynxeye.de>
 <20160425175326.407eba27@wiggum>
 <1461608496.2364.36.camel@lynxeye.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/_eXB0aCAKiqlE0mYSbtBOQY"; protocol="application/pgp-signature"
Cc: Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org
To: Lucas Stach <dev@lynxeye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:54003 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933242AbcDYSc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 14:32:59 -0400
In-Reply-To: <1461608496.2364.36.camel@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/_eXB0aCAKiqlE0mYSbtBOQY
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 25 Apr 2016 20:21:36 +0200
Lucas Stach <dev@lynxeye.de> wrote:

> > Numbers please. Did you measure that is actually causes more
> > _wakeups_?
> > How many?
> > The led work is placed in the mac80211 workqueue and LED updates only
> > happen on behalf of mac80211 activities (by default). It only causes
> > additional wakeups, if there's nothing else scheduled on the
> > workqueue
> > anyways (which might well be the case. So we need numbers. :)
> >  =20
> The blinking LEDs use a timer to enforce a constant blink rate at a
> 50ms on/off interval. While they are only triggered if there is some
> RX/TX activity in the system, they cause up to 20 wakeups/second/led.
> As the timers used for LED activity aren't deferrable, this hardcode is
> causing 40 unnecessary CPU wakeups/s in my system.


Ok this is 40 to 40k for the interrupt requests?
We need real measured numbers and a percentage on how much the b43 LEDs
increase the system wakeups in relation to all other wakeups.


> There are some people that find those kinds of blinking LEDs
> distracting,


Those can already disable them via the standard LED framework.


> so a module parameter to disable them altogether might be
> a good thing to have.


No. We have a standard API for this.


> Causing CPU wakeups in a system where those LEDs
> aren't even physically populated is clearly undesired behavior.


Yes, but this is not going to be fixed via regressions.


> If checking that the SPROM doesn't define any LED behavior is enough to
> not regress your use case, I would be glad to rework the patch
> accordingly.


As it turns out I don't have that card here and I don't have a dump of
its SPROM as I expected. So I cannot really verify this. But I'm pretty
sure that this card did not define any LEDs in its SPROM at all.
I'm not aware of any card that only partially defines LEDs in the
SPROM. So that fix would be OK.

--=20
Michael

--Sig_/_eXB0aCAKiqlE0mYSbtBOQY
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXHmKlAAoJEPUyvh2QjYsOnhkP/iPLgoytVI7FTHfRVli0QnJE
/8+5Cjpv/blHgXnRjUCy+qW9JMB6C0J64t8X8yBnFYH8S86SGIaZ/wA7ZFSbDD0o
KE7M3VEB5rCAq2ePc14Jk3JUbxzahgQPOxAYbg4GK0GDT/GWRmIXxW+T0gKP5U1d
FihcKpMCxZOfsKLoomNnwXjpZ68I2VJ31Xpt98VuNX3UyrPv7bgZhCHsR1xIl/0J
I65vkG4gXb09ajrd0aEVkLxOlopFMGFp9b0gLutf15IKEaqD1B7RqfkrmNxa/hSe
c9zBJVXd7xSaIwWKpGoWg94JnyEfX/R+KB7pK/OOQBab55datRCwKI4SO7NFjfXB
q7sBRKBwDDVq27Epfl0s+VNlt3qXZ5YfyLc5d7nee34bFjGM8TI+CGWPplgCKr2O
IjvzasJ2Hx4FSyrGIbCDMHp92uayAr3dgMyWwbnRSHGlcueREtkX6c3yYaB+48BI
uc+xnCYX939pQy065VO8qVYUCfzehR5Kcic3hu1S6HEmCb/MEQDev4h719LidAdy
H3ly+RqeZP8/cZ4NF8C5r+TaNEvgt996e8k+UVSBzsA2h04y9x8s9p+TcQaJsBRb
PVi5X9MMVVSscahW7tOeTO+tJjLE6rSL0hjUjwJqwD/NM7+vwS31Kbs0gIGj8aFJ
79MMfY/Cis3YkI1s+8Cr
=JbH+
-----END PGP SIGNATURE-----

--Sig_/_eXB0aCAKiqlE0mYSbtBOQY--
