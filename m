From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Mon, 14 Feb 2011 17:29:15 +0100
Message-ID: <1297700955.2996.40.camel@edumazet-laptop>
References: <4D594313.4050009@redhat.com>
	 <1297696283.2996.33.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>
	 <1297698641.2996.38.camel@edumazet-laptop>  <4D595745.7070505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>, Avi Kivity <avi@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D595745.7070505@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 14 f=C3=A9vrier 2011 =C3=A0 17:24 +0100, Patrick McHardy a =C3=
=A9crit :
> Am 14.02.2011 16:50, schrieb Eric Dumazet:
> > Le lundi 14 f=C3=A9vrier 2011 =C3=A0 16:18 +0100, Jan Engelhardt a =
=C3=A9crit :
> >> On Monday 2011-02-14 16:11, Eric Dumazet wrote:
> >>
> >>> Le lundi 14 f=C3=A9vrier 2011 =C3=A0 16:58 +0200, Avi Kivity a =C3=
=A9crit :
> >>>> We see severe memory corruption in kvm while used in conjunction=
 with=20
> >>>> bridge/netfilter.  Enabling slab debugging points the finger at =
a=20
> >>>> netfilter chain invoked from the bridge code.
> >>>>
> >>>> Can someone take a look?
> >>>>
> >>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D27052
> >>
> >> Maybe looks familiar to https://lkml.org/lkml/2011/2/3/147
> >=20
> > Are you sure Jan ?
> >=20
> > IMHO it looks like in your case, a NULL ->hook() is called, from
> > nf_iterate()
> >=20
> > BTW, list_for_each_continue_rcu() really should be converted to=20
> > list_for_each_entry_continue_rcu()
> >=20
> > This is a bit ugly :
> >=20
> > list_for_each_continue_rcu(*i, head) {
> > 	struct nf_hook_ops *elem =3D (struct nf_hook_ops *)*i;
> >=20
> > Also, I wonder if RCU rules are respected in nf_iterate().
> > For example this line is really suspicious :
> >=20
> > *i =3D (*i)->prev;
>=20
> Yeah, that definitely looks wrong. How about this instead?
>=20

This patch seems fine to me, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
