From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Thu, 3 Feb 2005 11:51:27 -0800
Message-ID: <20050203115127.3245951f@dxpl.pdx.osdl.net>
References: <20050202171702.24523.qmail@science.horizon.com>
	<1107365917.3754.155.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux@horizon.com, mingo@elte.hu, Arjan van de Ven
 <arjan@infradead.org>,
        bunk@stusta.de, Chris Wright <chrisw@osdl.org>, davem@redhat.com,
        Hank Leininger <hlein@progressive-comp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Valdis.Kletnieks@vt.edu, spender@grsecurity.net
To: Lorenzo =?ISO-8859-1?B?SGVybuFuZGV6IEdhcmPtYS1IaWVycm8=?=
 <lorenzo@gnu.org>
In-Reply-To: <1107365917.3754.155.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 02 Feb 2005 18:38:37 +0100
Lorenzo Hern=E1ndez Garc=EDa-Hierro <lorenzo@gnu.org> wrote:

> El mi=E9, 02-02-2005 a las 17:17 +0000, linux@horizon.com escribi=F3:
> > There *are* things in OpenBSD, like randomized port assignment (as op=
posed
> > to the linear scan in tcp_v4_get_port()) that would be worth emulatin=
g.
> > Maybe worry about that first?
> >=20

Recent 2.6 does a more advanced form of port randomization already
using address hash at connect time.  tcp_v4_get_port is only used for the=
 case
of applications that explicitly bind to port zero to find a free port.

So the sequence:
	socket(); connect();=20
will assign a random port in a manner similar to sequence number creation

The sequence:
	socket(); bind(); connect();
assigns a simple linear increasing port value.  It could be randomized, b=
ut
most applications don't bother binding, so the first case is sufficient.

--=20
Stephen Hemminger	<shemminger@osdl.org>
