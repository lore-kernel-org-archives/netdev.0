From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 26 Oct 2015 22:35:03 +0100
Message-ID: <C1235108-1DC2-408E-8CAC-65DBE628AB78@simula.no>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com> <1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com> <CADVnQykhCKU+5DyX1r73nRQjqw7qbM81yHgTzY5pG=h9kpj6Xw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Yuchung Cheng <ycheng@google.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?utf-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward4.uio.no ([129.240.10.33]:35458 "EHLO
	mail-forward4.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbbJZVrN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 17:47:13 -0400
Received: from exim by mail-out4.uio.no with local-bsmtp (Exim 4.80.1)
	(envelope-from <apetlund@simula.no>)
	id 1ZqpRj-00014t-7N
	for netdev@vger.kernel.org; Mon, 26 Oct 2015 22:36:51 +0100
In-Reply-To: <CADVnQykhCKU+5DyX1r73nRQjqw7qbM81yHgTzY5pG=h9kpj6Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 26 Oct 2015, at 15:50, Neal Cardwell <ncardwell@google.com> wrote:
>=20
> On Fri, Oct 23, 2015 at 4:50 PM, Bendik R=C3=B8nning Opstad
> <bro.devel@gmail.com> wrote:
>> @@ -2409,6 +2412,15 @@ static int do_tcp_setsockopt(struct sock *sk,=
 int level,
> ...
>> +       case TCP_RDB:
>> +               if (val < 0 || val > 1) {
>> +                       err =3D -EINVAL;
>> +               } else {
>> +                       tp->rdb =3D val;
>> +                       tp->nonagle =3D val;
>=20
> The semantics of the tp->nonagle bits are already a bit complex. My
> sense is that having a setsockopt of TCP_RDB transparently modify the
> nagle behavior is going to add more extra complexity and unanticipate=
d
> behavior than is warranted given the slight possible gain in
> convenience to the app writer. What about a model where the
> application user just needs to remember to call
> setsockopt(TCP_NODELAY) if they want the TCP_RDB behavior to be
> sensible? I see your nice tests at
>=20
>   https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04329d=
29b7d8baf703b2c2ac1b
>=20
> are already doing that. And my sense is that likewise most
> well-engineered "thin stream" apps will already be using
> setsockopt(TCP_NODELAY). Is that workable?

We have been discussing this a bit back and forth. Your suggestion woul=
d be the right thing to keep the nagle semantics less complex and to ed=
ucate developers in the intrinsics of the transport.

We ended up choosing to implicitly disable nagle since it=20
1) is incompatible with the logic of RDB.
2) leaving it up to the developer to read the documentation and registe=
r the line saying that "failing to set TCP_NODELAY will void the RDB la=
tency gain" will increase the chance of misconfigurations leading to de=
ployment with no effect.

The hope was to help both the well-engineered thin-stream apps and the =
ones deployed by developers with less detailed knowledge of the transpo=
rt.

-Andreas
