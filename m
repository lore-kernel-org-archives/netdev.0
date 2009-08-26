From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] 8 bytes kernel memory disclosure in AppleTalk getsockname.
Date: Wed, 26 Aug 2009 14:35:57 +0200
Message-ID: <4A952C2D.2010807@gmail.com>
References: <20090826111247.GA79673@clem1.netasq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Clement LECIGNE <clement.lecigne@netasq.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932922AbZHZMf7@vger.kernel.org>
In-Reply-To: <20090826111247.GA79673@clem1.netasq.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clement LECIGNE a =E9crit :
> Hi,
>=20
> In function atalk_getname(), sockaddr_at is returned in userland with=
out
> zero'ing the "char sat_zero[8]" field. This bug allows user to displa=
y 8
> bytes leaked from the kernel stack.
>=20
> Here is a patch that zero the whole sockaddr_at structure before
> processing it. It should fix this bug.
>=20
> Signed-off-by: Cl=E9ment Lecigne <clement.lecigne@netasq.com>
> --- linux/net/appletalk/ddp.c	2009-08-26 11:35:59.000000000 +0200
> +++ linux/net/appletalk/ddp.c	2009-08-26 11:36:30.000000000 +0200
> @@ -1241,6 +1241,8 @@ static int atalk_getname(struct socket *
>  		if (atalk_autobind(sk) < 0)
>  			return -ENOBUFS;
> =20
> +	memset(&sat, 0, sizeof(struct sockaddr_at));
> +
>  	*uaddr_len =3D sizeof(struct sockaddr_at);
> =20
>  	if (peer) {
>=20
Hi Clement

Well, I submitted same patch some weeks ago and I just checked that
it was already in Linus tree.

author	Eric Dumazet <eric.dumazet@gmail.com>
	Thu, 6 Aug 2009 02:27:43 +0000 (02:27 +0000)
committer	David S. Miller <davem@davemloft.net>
	Thu, 6 Aug 2009 20:08:45 +0000 (13:08 -0700)
commit	3d392475c873c10c10d6d96b94d092a34ebd4791

appletalk: fix atalk_getname() leak

atalk_getname() can leak 8 bytes of kernel memory to user

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>


Dont worry, it'll be included in upcoming 2.6.31 kernel,
and backported to previous ones as well.
