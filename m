From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: notifications of interfaces going down/up/being
 created/destroyed?
Date: Mon, 30 Mar 2015 13:59:34 -0700
Message-ID: <20150330205934.GA29542@f1.synalogic.ca>
References: <CAA93jw7u=aPjXVME5WwCa97tbD1-5XpgRPg_C9y2kH9qkrt1mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33946 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbbC3U7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 16:59:38 -0400
Received: by pdbni2 with SMTP id ni2so187147465pdb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 13:59:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA93jw7u=aPjXVME5WwCa97tbD1-5XpgRPg_C9y2kH9qkrt1mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/03/28 09:37, Dave Taht wrote:
> is there an asynchronous way to register for a notification of an
> interface going down/up?

Look at what `ip monitor` is doing.

>=20
> ---------- Forwarded message ----------
> From: Juliusz Chroboczek <jch@pps.univ-paris-diderot.fr>
> Date: Sat, Mar 28, 2015 at 9:30 AM
> Subject: Re: [Babel-users] Looping in EAGAIN
> To: Dave Taht <dave.taht@gmail.com>
> Cc: Simon Kelley <simon@thekelleys.org.uk>,
> "babel-users@lists.alioth.debian.org"
> <babel-users@lists.alioth.debian.org>
>=20
>=20
> > Say wlan0 vanishes. All the routes going out that interface are no
> > longer valid, but from what I understood of this patch, it will loo=
p for
> > a while, then give up.
>=20
> If wlan0 vanishes, this will be recognised the next time check_interf=
aces
> is run, and all neighbours visible through wlan0 will be flushed.
>=20
> The issue we're having is a race condition -- if wlan0 goes down and =
then
> back up before we run check_interfaces, and the IP addresses don't ch=
ange,
> then check_interfaces will not notice the transition, and Babel will =
think
> that its routes through wlan0 are still up -- end you end up with a F=
IB
> that is not a subset of the RIB.  Ouch.
>=20
> So it might be a good idea to run check_interfaces early when we get
> EAGAIN, but I'm not sure what consequences it might have -- EAGAIN ca=
n
> also happen when we're under load, and we'd rather not be repeatedly
> scanning our interfaces in that case.
>=20
> It would be better to get async notifications from the kernel about
> interfaces going down.
>=20
> > Not clear to me if this would happen for 4 hello intervals before t=
he
> > interface is recognised as gone?
>=20
> No, the hellos are used to notice vanishing neighbours, not vanishing
> interfaces.  That's a completely different mechanism.
>=20
> -- Juliusz
>=20
>=20
> --=20
> Dave T=E4ht
> Let's make wifi fast, less jittery and reliable again!
>=20
> https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
