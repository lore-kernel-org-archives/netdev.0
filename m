From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: fix search limit handling in skb_find_text()
Date: Thu, 18 Jun 2015 22:01:31 +0200
Message-ID: <20150618200131.GA3506@salvia>
References: <1434359518-16897-1-git-send-email-khimov@altell.ru>
 <1847765.0Hbie9lSro@mate.hex>
 <20150616104841.GA4163@salvia>
 <6185418.JcpCEFvK8k@sencha>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Thomas Graf <tgraf@suug.ch>
To: Roman Khimov <khimov@altell.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58533 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753609AbbFRT4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 15:56:09 -0400
Content-Disposition: inline
In-Reply-To: <6185418.JcpCEFvK8k@sencha>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 03:13:41PM +0300, Roman Khimov wrote:
> =D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 16 =D0=B8=D1=
=8E=D0=BD=D1=8F 2015 12:48:41 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=
=D0=B0=D1=82=D0=B5=D0=BB=D1=8C Pablo Neira Ayuso =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB:
[...]
> > But if we change the existing behaviour, users may be relying on it
> > and we'll get things broken for them. Someone else will come later =
one
> > with another patch to say: "hey, --to used to be inclusive but this=
 is
> > not the case anymore and it's breaking my setup".
>=20
> I do understand your concerns, but fixing it this way would require c=
hanging=20
> skb_seq_read() and basicaly would propagate "'to' offset included" se=
mantics=20
> (which seems a bit strange for programmers, IMO) further. And initial=
ly I=20
> thought that changing skb_seq_read() would be more intrusive, althoug=
h looking=20
> at all this now it looks like the only real user of upper_offset fiel=
d in=20
> ts_config struct is skb_find_text(), because other invocations of=20
> skb_seq_read() from drivers/scsi/libiscsi_tcp.c and net/batman-adv/ma=
in.c use=20
> skb->len as an upper limit.
>=20
> > > em_text_match() in net/sched/em_text.c is also suspicious.
> >=20
> > Please, elaborate.
>=20
> The way it constructs 'to' offset, I think it doesn't expect somethin=
g to=20
> match at 'to'. Although I might be wrong here.

Could you send a patch that resolves the inconsistency for programmers
while leaving the userspace exposed behaviour through xt_string and
em_string intact? Thanks.
