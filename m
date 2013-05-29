From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Tue, 28 May 2013 18:31:11 -0700
Message-ID: <20130529013111.GS6172@linux.vnet.ibm.com>
References: <519CB2D8.103@yandex-team.ru>
 <1369225837.3301.324.camel@edumazet-glaptop>
 <519CC2FB.2010006@yandex-team.ru>
 <20130522174532.GC3431@linux.vnet.ibm.com>
 <519D19DA.50400@yandex-team.ru>
 <20130525113715.GA3795@linux.vnet.ibm.com>
 <51A39E11.5020405@yandex-team.ru>
 <1369699930.3301.494.camel@edumazet-glaptop>
 <51A47496.6000100@yandex-team.ru>
 <1369787693.3301.586.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roman Gushchin <klamm@yandex-team.ru>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369787693.3301.586.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 28, 2013 at 05:34:53PM -0700, Eric Dumazet wrote:
> On Tue, 2013-05-28 at 13:10 +0400, Roman Gushchin wrote:
> > On 28.05.2013 04:12, Eric Dumazet wrote:
>=20
> > > Adding a barrier() is probably what we want.
> >=20
> > I agree, inserting barrier() is also a correct and working fix.
>=20
> Yeah, but I can not find a clean way to put it inside the "for (;;)"
>=20
> for (barrier();;)  ->
>=20
> error: expected expression before =E2=80=98__asm__=E2=80=99
>=20
> No user currently does :
>=20
> if (condition)
> 	hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)
>=20
> But who knows...

I still have my earlier question, but I suggest "({ barrier(); XXX })"
to put the barrier into the for loop, either in the second or third
clause, where XXX was the original second or third clause.

							Thanx, Paul
