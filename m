From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Tue, 22 Dec 2015 22:13:36 +0200
Message-ID: <5433032.ornV7UU4Xc@spock>
References: <26396443.iDTTxgChSj@spock> <CAK6E8=d1FquYTtMXi6v+koruRhA2MUe693-DX5jbU8urRatUoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=d1FquYTtMXi6v+koruRhA2MUe693-DX5jbU8urRatUoQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That is correct, I have net.ipv4.tcp_ecn set to 1.

I've recompiled the kernel with proposed patch, now still waiting for i=
ssue to=20
be triggered.

Could I manually simulate the erroneous TCP ECN behavior to speed up th=
e=20
debugging?

On =D0=BF=D0=BE=D0=BD=D0=B5=D0=B4=D1=96=D0=BB=D0=BE=D0=BA, 21 =D0=B3=D1=
=80=D1=83=D0=B4=D0=BD=D1=8F 2015 =D1=80. 18:10:32 EET Yuchung Cheng wro=
te:
> On Mon, Dec 21, 2015 at 12:25 PM, Oleksandr Natalenko
>=20
> <oleksandr@natalenko.name> wrote:
> > Commit 3759824da87b30ce7a35b4873b62b0ba38905ef5 (tcp: PRR uses CRB =
mode by
> > default and SS mode conditionally) introduced changes to
> > net/ipv4/tcp_input.c tcp_cwnd_reduction() that, possibly, cause div=
ision
> > by zero, and therefore, kernel panic in interrupt handler [1].
> >=20
> > Reverting 3759824da87b30ce7a35b4873b62b0ba38905ef5 seems to fix the=
 issue.
> >=20
> > I'm able to reproduce the issue on 4.3.0=E2=80=934.3.3 once per sev=
eral day
> > (occasionally).
> >=20
> > What could be done to help in debugging this issue?
>=20
> Do you have ECN enabled (i.e. sysctl net.ipv4.tcp_ecn > 0)?
>=20
> If so I suspect an ACK carrying ECE during CA_Loss causes entering CW=
R
> state w/o calling tcp_init_cwnd_reduct() to set tp->prior_cwnd. Can
> you try this debug / quick-fix patch and send me the error message if
> any?
>=20
> > Regards,
> >=20
> >   Oleksandr.
> >=20
> > [1] http://i.piccy.info/
> > i9/6f5cb187c4ff282d189f78c63f95af43/1450729403/283985/951663/panic.=
jpg
