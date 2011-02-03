From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: epoll broken [was: mmotm 2011-01-25-15-47 uploaded]
Date: Thu, 03 Feb 2011 08:53:21 +0100
Message-ID: <1296719601.3438.0.camel@edumazet-laptop>
References: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
	 <4D4A5BBF.20806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
	davidel@xmailserver.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D4A5BBF.20806@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 03 f=C3=A9vrier 2011 =C3=A0 08:39 +0100, Jiri Slaby a =C3=A9cr=
it :
> On 01/26/2011 12:48 AM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2011-01-25-15-47 has been uploaded to
>=20
> Hi, the network daemons are broken here. cupsd and httpd children
> segfault too often without servicing requests. It's a regression agai=
nst
> mmotm 2011-01-06-15-41.
>=20
> It's epoll after it dies:
> 17836 epoll_create(8192)                =3D 3
> ...
> 17836 accept(7, {sa_family=3DAF_FILE, NULL}, [2]) =3D 11
> 17836 getsockname(11, {sa_family=3DAF_FILE,
> path=3D"/var/run/cups/cups.sock"}, [26]) =3D 0
> 17836 setsockopt(11, SOL_TCP, TCP_NODELAY, [1], 4) =3D -1 EOPNOTSUPP
> (Operation not supported)
> 17836 fcntl(11, F_GETFD)                =3D 0
> 17836 fcntl(11, F_SETFD, FD_CLOEXEC)    =3D 0
> 17836 epoll_ctl(3, EPOLL_CTL_ADD, 11, {EPOLLIN, {u32=3D379708832,
> u64=3D140428630418848}}) =3D 0
> 17836 epoll_wait(3, {{EPOLLIN, {u32=3D379708832, u64=3D14042863041884=
8}}},
> 8192, 1000) =3D 1
> 17836 recvfrom(11, "P", 1, MSG_PEEK, NULL, NULL) =3D 1
> 17836 poll([{fd=3D11, events=3DPOLLIN}], 1, 10000) =3D 1 ([{fd=3D11,
> revents=3DPOLLIN}])
> 17836 recvfrom(11, "POST / HTTP/1.1\r\nContent-Length:"..., 2048, 0,
> NULL, NULL) =3D 771
> 17836 sendto(11, "HTTP/1.1 100 Continue\r\n\r\n", 25, 0, NULL, 0) =3D=
 25
> 17836 epoll_wait(3, {{EPOLLIN, {u32=3D379708832, u64=3D14042863041884=
8}},
> {0, {u32=3D0, u64=3D0}} .............. {0, {u32=3D0, u64=3D0}}, ?}
> 0x7fb816996660, 8192, 0) =3D 379151968
> 17836 --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> 17836 +++ killed by SIGSEGV +++
>=20
> The parameter, the same as the retval, seems to be bogus.
>=20
> Is it known (fixed in newer kernels)?
>=20
> thanks,

Yes, its known, and a fix is there : https://lkml.org/lkml/2011/1/26/12=
1
