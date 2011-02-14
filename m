From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Mon, 14 Feb 2011 16:50:41 +0100
Message-ID: <1297698641.2996.38.camel@edumazet-laptop>
References: <4D594313.4050009@redhat.com>
	 <1297696283.2996.33.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:37704 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679Ab1BNPuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 10:50:46 -0500
In-Reply-To: <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 f=C3=A9vrier 2011 =C3=A0 16:18 +0100, Jan Engelhardt a =C3=A9=
crit :
> On Monday 2011-02-14 16:11, Eric Dumazet wrote:
>=20
> >Le lundi 14 f=C3=A9vrier 2011 =C3=A0 16:58 +0200, Avi Kivity a =C3=A9=
crit :
> >> We see severe memory corruption in kvm while used in conjunction w=
ith=20
> >> bridge/netfilter.  Enabling slab debugging points the finger at a=20
> >> netfilter chain invoked from the bridge code.
> >>=20
> >> Can someone take a look?
> >>=20
> >> https://bugzilla.kernel.org/show_bug.cgi?id=3D27052
>=20
> Maybe looks familiar to https://lkml.org/lkml/2011/2/3/147

Are you sure Jan ?

IMHO it looks like in your case, a NULL ->hook() is called, from
nf_iterate()

BTW, list_for_each_continue_rcu() really should be converted to=20
list_for_each_entry_continue_rcu()

This is a bit ugly :

list_for_each_continue_rcu(*i, head) {
	struct nf_hook_ops *elem =3D (struct nf_hook_ops *)*i;

Also, I wonder if RCU rules are respected in nf_iterate().
=46or example this line is really suspicious :

*i =3D (*i)->prev;



