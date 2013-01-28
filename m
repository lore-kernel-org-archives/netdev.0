From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] soreuseport: fix use of uid in tb->fastuid
Date: Mon, 28 Jan 2013 08:47:07 +0100
Message-ID: <20130128074707.GN9147@secunet.com>
References: <alpine.DEB.2.00.1301260944370.27231@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55694 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606Ab3A1HrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 02:47:09 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1301260944370.27231@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2013 at 09:50:54AM -0800, Tom Herbert wrote:
> Fix a reported compilation error where ia variable of type kuid_t
> was being set to zero.
>=20

Thanks for fixing this.
Unfortunately I get another compilation error now:

net/ipv6/inet6_connection_sock.c: In function =E2=80=98inet6_csk_bind_c=
onflict=E2=80=99:
net/ipv6/inet6_connection_sock.c:37:12: error: incompatible types when =
initializing type =E2=80=98int=E2=80=99 using type =E2=80=98kuid_t=E2=80=
=99
net/ipv6/inet6_connection_sock.c:54:30: error: incompatible type for ar=
gument 1 of =E2=80=98uid_eq=E2=80=99
include/linux/uidgid.h:70:20: note: expected =E2=80=98kuid_t=E2=80=99 b=
ut argument is of type =E2=80=98int=E2=80=99
make[3]: *** [net/ipv6/inet6_connection_sock.o] Error 1

I wondered why noone else is seeing this, so I did some analysis.
I'm getting this because of the UIDGID_STRICT_TYPE_CHECKS config option=
=2E
This is selected by USER_NS which in turn depends on UIDGID_CONVERTED.
Most people can't enable USER_NS because they compile something like
nfs or anything else that is not 'UIDGID_CONVERTED'.
