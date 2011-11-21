From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Tue, 22 Nov 2011 07:27:55 +1100
Message-ID: <1321907275.13860.12.camel@pasglop>
References: <20111121131531.GA1679@x4.trippels.de>
	 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121153621.GA1678@x4.trippels.de>
	 <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121161036.GA1679@x4.trippels.de>
	 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
	 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	 <20111121195113.GA1678@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Christoph Lameter
 <cl@linux-foundation.org>,
        Pekka Enberg <penberg@kernel.org>, Matt Mackall
 <mpm@selenic.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>, Christian Kujau <lists@nerdbynature.de>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111121195113.GA1678@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-21 at 20:51 +0100, Markus Trippelsdorf wrote:
> On 2011.11.21 at 19:52 +0100, Markus Trippelsdorf wrote:
> > On 2011.11.21 at 19:39 +0100, Eric Dumazet wrote:
> > > Le lundi 21 novembre 2011 =C3=A0 18:35 +0100, Markus Trippelsdorf a=
 =C3=A9crit :
> > >=20
> > > > New one:
> > >=20
> > > ...
> > >=20
> > > I was just wondering if you were using CONFIG_CGROUPS=3Dy, and if y=
es, if
> > > you could try to disable it.
> >=20
> > # CONFIG_CGROUPS is not set
> >=20
> > (I never enable CGROUPS on my machines)
>=20
> Just for the record, I've attached full dmesg and my .config.
> (Will continue testing tomorrow)

Note that I hit a similar looking crash (sorry, I couldn't capture a
backtrace back then) on a PowerMac G5 (ppc64) while doing a large rsync
transfer yesterday with -rc2-something (cfcfc9ec) and=20
Christian Kujau (CC) seems to be able to reproduce something similar on
some other ppc platform (Christian, what is your setup ?)

We haven't hit the poison checks, more like bad pointer derefs, almost
always in SLUB coming from skb alloc or free.

In my case, it's not easy to reproduce, so a bisection would be
error-prone.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
