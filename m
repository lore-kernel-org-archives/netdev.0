From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Mon, 26 Oct 2009 10:47:19 +0200
Message-ID: <4AE56217.3040708@imap.cc>
References: <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>	 <20091021211906.GA11401@ami.dom.local>	 <1256160330.12174.2.camel@johannes.local>	 <20091021213947.GA12202@ami.dom.local>	 <1256200021.12174.11.camel@johannes.local> <4AE1C00B.5010008@imap.cc>	 <1256309191.12174.51.camel@johannes.local>	 <20091026074126.GA6187@ff.dom.local>	 <1256543054.28230.6.camel@johannes.local>	 <20091026075438.GB6187@ff.dom.local> <1256543932.28230.9.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1256543932.28230.9.camel@johannes.local>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 26.10.2009 09:58 schrieb Johannes Berg:
> On Mon, 2009-10-26 at 07:54 +0000, Jarek Poplawski wrote:
>=20
>>> No, I wrote that I didn't know. I suppose now that I looked at it I=
 do
>>> know, and only disabling preemption is required.
>> But netif_rx has preemption disabled most of the time (by hardirqs
>> disabling). So maybe disabling preemption isn't the main reason here
>> either?
>=20
> Not for netpoll though, which may or may not be relevant (if I were t=
o
> venture a guess I'd say it isn't and it disables preemption to be abl=
e
> to do the softirq thing)
>=20
> However, I lost track now of why we're discussing this.

The starting point were several reports of the kernel message:

NOHZ: local_softirq_pending 08

Originally most if not all of them came from wireless networking,
but I muddied the waters by adding to the mix a case involving ISDN.
You stated that all the solutions proposed so far were wrong, so
we're naturally turning to you for guidance on what the right
solution might be.

> Basically it boils down to using netif_rx() when in (soft)irq, and
> netif_rx_ni() when in process context. That could just be an
> optimisation, but it's a very valid one.

Hmmm. That seems to contradict your earlier statement to me that
simply replacing a call to netif_rx() by one to netif_rx_ni()
when not in interrupt context isn't a valid solution either.
What am I missing?

Thanks,
Tilman

- --
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFK5WIXQ3+did9BuFsRAsj1AJ0e4VJ7Nsp69ROXCiT4oM/Q6lIpSwCfZvXS
4nV4tWTIzgk4IRlCt0CCF3Y=3D
=3Dr15I
-----END PGP SIGNATURE-----
