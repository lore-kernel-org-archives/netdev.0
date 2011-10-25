From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next V4] net: introduce ethernet teaming device
Date: Tue, 25 Oct 2011 11:22:56 -0200
Message-ID: <20111025112256.5c0d6c06@asterix.rh>
References: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
	<CAHXqBFLzuxaCW-q5X066zM3E_t9KHO1uTF6WD3Je2u0EifaSSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933399Ab1JYNXP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 09:23:15 -0400
In-Reply-To: <CAHXqBFLzuxaCW-q5X066zM3E_t9KHO1uTF6WD3Je2u0EifaSSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Oct 2011 19:22:36 +0200
Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:

> 2011/10/24 Jiri Pirko <jpirko@redhat.com>:
> > This patch introduces new network device called team. It supposes
> > to be very fast, simple, userspace-driven alternative to existing
> > bonding driver.
> [...]
> > =C2=A0drivers/net/team/team.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | 1573
> > +++++++++++++++++++++++++++++
> > drivers/net/team/team_mode_activebackup.c | =C2=A0152 +++
> > drivers/net/team/team_mode_roundrobin.c =C2=A0 | =C2=A0107 ++
>=20
> I think this mode-modularity is overkill. One mode will compile to at
> most a few hundred bytes of code+data, but will use at least 10 times
> that to get loaded and tracked properly. How often/how many more mode=
s
> you anticipate to be introduced? You could just keep the modular
> design but drop the kernel module separation and maybe have modes
> conditionally compiled (for those from the embedded world squeezing
> every byte).
>=20

Please keep the modes separated.  Security and embedded folks will
thank you.  If you are concerned with the overhead which still should
be small and doesn't impact performance, you can compile as built-in.
The good thing is that you can choose the best option for you while
doing the opposite doesn't offer that.

Also, if in the future we need to add module parameters, the namespace
is clean.

I would ask to keep it as the work is done already.

fbl
