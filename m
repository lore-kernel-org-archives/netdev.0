From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Mon, 23 Mar 2009 19:04:10 +0100
Message-ID: <OF2B3BD0A1.5412596B-ONC1257582.00630A40-C1257582.00634206@transmode.se>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CBB2.4020205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:42930 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754852AbZCWSEM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 14:04:12 -0400
In-Reply-To: <49C7CBB2.4020205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote on 23/03/2009 18:49:38:

>=20
> Joakim Tjernlund a =E9crit :
> > Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:29:33:
> >=20
> >> Joakim Tjernlund wrote:
> >>> Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:15:45:
> >>>> Joakim Tjernlund wrote:
> >>>>> doing a "ping -f -l 3" on my host towards my board on linus tre=
e=20
as=20
> > of=20
> >>>>> Friday results in lots of:
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>> __ratelimit: 11 callbacks suppressed
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>> nf_conntrack: table full, dropping packet.
> >>>>>
> >>>>> for ucc_geth on a MPC832x.
> >>>>> This really looks strange to me, ideas?
> >>>> What does /proc/net/netfilter/nf_conntrack show?
> >>> There is no /proc/net/netfilter/nf_conntrack. There is a
> >>> /proc/net/nf_conntrack though and it is empty. If I telnet
> >>> to the board I see:
> >> That means that something is leaking conntrack references, most=20
likely
> >> by leaking skbs. Since I haven't seen any other reports, my guess=20
would
> >> be the ucc_geth driver.
> >>
> >=20
> > Mucking around with the ucc_geth driver I found that if I:
> >  - Move TX from IRQ to NAPI context
> >  - double the weight.
> >  - after booting up, wait a few mins until the JFFS2 GC kernel thre=
ad=20
has=20
> > stopped
> >    scanning the FS=20
> >=20
> > Then the "nf_conntrack: table full, dropping packet." msgs stops.
> > Does this seem right to you guys?
> >=20
>=20
> How many cpus do you have ?

Just one, it is an embedded board running at 266 MHz

>=20
> What kernel version do you use ?

Linus tree as of Friday

