From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 10:03:15 +0400
Message-ID: <20080531060315.GA2692@2ka.mipt.ru>
References: <48402BD7.2080705@madrabbit.org> <Pine.LNX.4.64.0805302105170.1761@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ray Lee <ray-lk@madrabbit.org>, Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754369AbYEaGED@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805302105170.1761@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 31, 2008 at 12:11:32AM +0300, Ilpo J=C3=A4rvinen (ilpo.jarv=
inen@helsinki.fi) wrote:
> > > > Active Internet connections (w/o servers)
> > > > Proto Recv-Q Send-Q Local Address               Foreign Address
> > > > State
> > > > tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632 =
 ESTABLISHED
> > > > tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015=
 ESTABLISHED
>=20
>              ^^^^^
>=20
> Can you perhaps find/guess/think some explanation for this _receiver=20
> queue_...? This was a trick question :-), as we already know that the=
=20
> receiving process is no longer there and therefore obviously won't be=
=20
> reading anything anymore. But that opened another question, why TCP i=
s=20
> then still in ESTABLISHED as orphaned TCP shouldn't be in establised =
state=20
> anymore, tcp_close should have changed the state (either at close or =
at=20
> process exit). I guess once it becomes known why tcp_close either was=
n't=20
> called at all or it didn't change the state of the flow (it's quite=20
> simple, see for yourself), the cause of the bug is found (it might ev=
en be=20
> that the process went away when it shouldn't have, either a bookkeepi=
ng=20
> bug somewhere or real death, or something along those lines).

In that case pid Ingo straced was still valid and existed (ans stuck
probably in tcp_sendpage() - sysrq-t dump was messy), so process still
exist, but sock somewhat lost its reference to socket. AFICS all (three=
)
calls for sk_orphan() can not happen without state change to something
closing (like fin wait or close), except some linger things and
listening socket, which frees its connection requests.

--=20
	Evgeniy Polyakov
