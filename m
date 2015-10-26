From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 26 Oct 2015 10:50:11 -0400
Message-ID: <CADVnQykhCKU+5DyX1r73nRQjqw7qbM81yHgTzY5pG=h9kpj6Xw@mail.gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
	<1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
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
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 4:50 PM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
>@@ -2409,6 +2412,15 @@ static int do_tcp_setsockopt(struct sock *sk, i=
nt level,
=2E..
> +       case TCP_RDB:
> +               if (val < 0 || val > 1) {
> +                       err =3D -EINVAL;
> +               } else {
> +                       tp->rdb =3D val;
> +                       tp->nonagle =3D val;

The semantics of the tp->nonagle bits are already a bit complex. My
sense is that having a setsockopt of TCP_RDB transparently modify the
nagle behavior is going to add more extra complexity and unanticipated
behavior than is warranted given the slight possible gain in
convenience to the app writer. What about a model where the
application user just needs to remember to call
setsockopt(TCP_NODELAY) if they want the TCP_RDB behavior to be
sensible? I see your nice tests at

   https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04329d2=
9b7d8baf703b2c2ac1b

are already doing that. And my sense is that likewise most
well-engineered "thin stream" apps will already be using
setsockopt(TCP_NODELAY). Is that workable?

neal
