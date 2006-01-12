From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/4 - 2.6.15]net: 32 bit (socket layer) ioctl emulation for 64 bit kernels
Date: Thu, 12 Jan 2006 19:24:02 +0000
Message-ID: <200601121924.02747.arnd@arndb.de>
References: <1137045732.5221.21.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Andi Kleen <ak@muc.de>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, SP <pereira.shaun@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161206AbWALTYX@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1137045732.5221.21.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 January 2006 06:02, Shaun Pereira wrote:
> +int compat_sock_get_timestamp(struct sock *sk, struct timeval __user
> *userstamp)
> +{
> +=A0=A0=A0=A0=A0=A0=A0struct compat_timeval __user *ctv;
> +=A0=A0=A0=A0=A0=A0=A0ctv =3D (struct compat_timeval __user*) usersta=
mp;
> +=A0=A0=A0=A0=A0=A0=A0if(!sock_flag(sk, SOCK_TIMESTAMP))
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sock_enable_timestamp(s=
k);
> +=A0=A0=A0=A0=A0=A0=A0if(sk->sk_stamp.tv_sec =3D=3D -1)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -ENOENT;
> +=A0=A0=A0=A0=A0=A0=A0if(sk->sk_stamp.tv_sec =3D=3D 0)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0do_gettimeofday(&sk->sk=
_stamp);
> +=A0=A0=A0=A0=A0=A0=A0return copy_to_user(ctv, &sk->sk_stamp, sizeof(=
struct
> compat_timeval)) ?
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
-EFAULT : 0;
> +}

This looks wrong, you're not doing any conversion here.
You cannot just copy sk_stamp to ctv, they are not compatible.
See compat_sys_gettimeofday on how to copy a struct timeval
correctly.

The other patches look good.

	Arnd <><
