From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 22:40:46 +0100
Message-ID: <1295559646.2613.35.camel@edumazet-laptop>
References: <20110119.180418.216749267.davem@davemloft.net>
	 <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 janvier 2011 =C3=A0 13:12 -0800, Linus Torvalds a =C3=A9cri=
t :



>   ...
>   read(3, 0x9806500, 4096)                =3D -1 EAGAIN (Resource
> temporarily unavailable)
>   poll([{fd=3D4, events=3DPOLLIN}, {fd=3D3, events=3DPOLLIN}, {fd=3D1=
2,
> events=3DPOLLIN|POLLPRI}, {fd=3D14, events=3DPOLLIN|POLLPRI}, {fd=3D9=
,
> events=3DPOLLIN|POLLPRI}, {fd=3D10, events=3DPOLLIN|POLLPRI}, {fd=3D1=
5,
> events=3DPOLLIN}, {fd=3D16, events=3DPOLLIN}, {fd=3D17, events=3D0}, =
{fd=3D19,
> events=3DPOLLIN}], 10, -1) =3D ? ERESTART_RESTARTBLOCK (To be restart=
ed)
>   restart_syscall(
>=20

Hmm, poll() here on fd=3D3 only asks events=3DPOLLIN

> and that's it - it's now hung. So why did it work when I straced it
> while hung? And why is it doing that ERESTART_RESTARTBLOCK in the
> first place, I'm not seeing any signals there?
>=20
> So I tried sending it a useless signal, which will re-animate the
> strace, and now I get:
>=20
>   restart_syscall(<... resuming interrupted call ...>) =3D 1
>   --- SIGWINCH (Window changed) @ 0 (0) ---
>   poll([{fd=3D3, events=3DPOLLIN|POLLOUT}], 1, -1) =3D 1 ([{fd=3D3, r=
events=3DPOLLOUT}])
>=20

Then here ask for fd=3D3 both POLLIN and POLLOUT :
kernel answers : OK for POLLOUT (not POLLIN), so previous poll() call
was OK to be blocked after all...

So I'm wondering if it could be a userland bug, that triggers with
recent kernel changes.
