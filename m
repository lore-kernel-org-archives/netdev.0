From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Tue, 27 Oct 2009 01:52:17 +0100
Message-ID: <4AE64441.7060008@imap.cc>
References: <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>	 <20091021211906.GA11401@ami.dom.local>	 <1256160330.12174.2.camel@johannes.local>	 <20091021213947.GA12202@ami.dom.local>	 <1256200021.12174.11.camel@johannes.local> <4AE1C00B.5010008@imap.cc>	 <1256309191.12174.51.camel@johannes.local>	 <20091026074126.GA6187@ff.dom.local>	 <1256543054.28230.6.camel@johannes.local>	 <20091026075438.GB6187@ff.dom.local>	 <1256543932.28230.9.camel@johannes.local>  <4AE56217.3040708@imap.cc> <1256547380.28230.17.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9CB782960AE172AE34570203"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1256547380.28230.17.camel@johannes.local>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9CB782960AE172AE34570203
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 26.10.2009 09:56 schrieb Johannes Berg:
> On Mon, 2009-10-26 at 10:47 +0200, Tilman Schmidt wrote:
>=20
>>> Basically it boils down to using netif_rx() when in (soft)irq, and
>>> netif_rx_ni() when in process context. That could just be an
>>> optimisation, but it's a very valid one.
>> Hmmm. That seems to contradict your earlier statement to me that
>> simply replacing a call to netif_rx() by one to netif_rx_ni()
>> when not in interrupt context isn't a valid solution either.
>> What am I missing?
>=20
> Well, I think you misunderstood me. It would be correct to do this, if
> and only if the code that calls it doesn't need the extra guarantee.

I see. Thanks for the clarification.

> Any code (say ISDN code) that calls netif_rx() is clearly assuming to
> always be running in (soft)irq context, otherwise it couldn't call
> netif_rx() unconditionally. Agree so far?

Well, in fact I'm not sure. :-) All I know is that in the ISDN case, no
such assumption is explicitly stated anywhere. (The code in question is
called from the rcvcallb_skb() callback method which the hardware driver
calls when data has been received, and the description of that method in
Documentation/isdn/INTERFACE does not say anything about the context in
which it may be called.) The relevant code in drivers/isdn/i4l/isdn_ppp.c=

is rather old, perhaps even older than softirqs and the netif_rx() /
netif_rx_ni() split. (Bear in mind that we are talking about the old
ISDN4Linux subsystem which initially didn't even make it into the 2.6
series because it was considered obsolete.) It seems quite possible to me=

that just no one ever thought about that question.

> So now if you change the ISDN code to call netif_rx_ni(), you've change=
d
> the assumption that the ISDN code makes -- that it is running in
> (soft)irq context. Therefore, you need to verify that this is actually =
a
> correct change, which is what I tried to say.

Understood. However, the fact that the local_softirq_pending message is
appearing would seem to indicate that this assumption was wrong to
begin with, wouldn't it?

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig9CB782960AE172AE34570203
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFK5kRMQ3+did9BuFsRAs2XAJ9Dc41aEw1ygQMbRfDKiz8ccup6JQCfSJ8V
ekRoH53k8F2iixXqlGU6u38=
=ku7z
-----END PGP SIGNATURE-----

--------------enig9CB782960AE172AE34570203--
