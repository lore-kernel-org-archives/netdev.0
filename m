From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Thu, 1 Mar 2007 15:34:35 -0800
Message-ID: <20070301153435.20121066@freekitty>
References: <45E5570E.7050301@free.fr>
	<200702281555.10309.dada1@cosmosbay.com>
	<45E5A8AE.3030606@free.fr>
	<200703011230.50596.dada1@cosmosbay.com>
	<20070301105348.04c2fd82@freekitty>
	<45E75E5D.9070508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John find <linux.kernel@free.fr>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <45E75E5D.9070508@cosmosbay.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Mar 2007 00:14:37 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
>=20
> >=20
> > You probably want to add a SO_TIMESTAMPNS setsockopt() value like e=
xisting SO_TIMESTAMP
>=20
> You mean an alias like this ?
>=20
> #define SO_TIMESTAMPNS SO_TIMESTAMP
>=20
> Or should we really use another value ?

Another value since if someone turns on SO_TIMESTAMP they want usec (ti=
meval)
and SO_TIMESTAMPNS would be for nanosecond values. Trying to set both
flags would be not allowed.

- original -

     If the SO_TIMESTAMP option is enabled on a SOCK_DGRAM socket, the
     recvmsg(2) call will return a timestamp corresponding to when the =
data-
     gram was received.  The msg_control field in the msghdr structure =
points
     to a buffer that contains a cmsghdr structure followed by a struct
     timeval.  The cmsghdr fields have the following values:

     cmsg_len =3D sizeof(struct timeval)
     cmsg_level =3D SOL_SOCKET
     cmsg_type =3D SCM_TIMESTAMP

- add -
     If the SO_TIMESTAMPNS option is enabled on a SOCK_DGRAM socket,
=2E..
     cmsg_len =3D sizeof(struct timespec)
     cmsg_level =3D SOL_SOCKET
     cmsg_type =3D SCM_TIMESTAMPNS
--=20
Stephen Hemminger <shemminger@linux-foundation.org>
