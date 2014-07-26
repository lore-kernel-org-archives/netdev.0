From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [PATCH 1/1] neighbour : fix ndm_type type error issue
Date: Sat, 26 Jul 2014 23:05:14 +0800
Message-ID: <1406387114.4985.6.camel@popy-debian>
References: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
	 <1406330697.989.145785925.1CA960AF@webmail.messagingengine.com>
	 <1406334557.5276.13.camel@popy-debian>
	 <1406382166.19420.145911853.784D75D0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Francesco Fusco <ffusco@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	David Stevens <dlstevens@us.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406382166.19420.145911853.784D75D0@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Hannes

On Sat, 2014-07-26 at 15:42 +0200, Hannes Frederic Sowa wrote:
> Hi,
>=20
> On Sat, Jul 26, 2014, at 02:29, Jun Zhao wrote:
> > On Sat, 2014-07-26 at 01:24 +0200, Hannes Frederic Sowa wrote:
> > > On Fri, Jul 25, 2014, at 18:38, Jun Zhao wrote:
> > > > ndm_type means L3 address type, in neighbour proxy and vxlan, i=
t's
> > > > RTN_UNICAST.
> > > > NDA_DST is for netlink TLV type, hence it's not right value in =
this
> > > > context.
> > >=20
> > > The value of NDA_DST =3D=3D RTN_UNICAST, otherwise we couldn't do=
 this
> > > change as it would alter e.g. arpd behavior.
> > >=20
> > > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > >=20
> > > Thanks,
> > > Hannes
> >=20
> > But I think NDA_DST/RTN_UNICAST have different means in this contex=
t,=20
> > even though the value of NDA_DST =3D=3D RTN_UNICAST.
> >=20
> > For arp proxy/NDP proxy context, ndm_type means the peer L3 address=
,
> > so RTN_UNICAST is the right value. For vxlan have similar semantic =
for
> > remote ip.
> >=20
> > BTW: In the source code, implicit think NDA_DST =3D=3D RTN_UNICAST =
maybe
> > not a good idea when we don't have a comment or the other explain.
>=20
> I am totally with you and think your change is good, that's why I als=
o
> gave my ack to your patch.
>=20
> My comment above was about my concerns regarding making a user space
> visible change, which in the end could alter the behavior of already
> existing software.
>=20
> Developers maybe have debugged code and seen some different value bei=
ng
> propagated from the kernel and this software could now break if we wo=
uld
> change the value after all those years.
>=20
> Bye,
> Hannes

Lucky=EF=BC=8C NDA_DST =3D=3D RTN_UNICAST is true really in source code=
 =EF=BC=9A=EF=BC=89

/* rtm_type */

enum {
	RTN_UNSPEC,
	RTN_UNICAST,	=09
=2E..
}

enum {
	NDA_UNSPEC,
	NDA_DST,
=2E..
}
