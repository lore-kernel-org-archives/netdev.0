From: Fabio Olive Leite <fabio.olive-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 14546] New: Off-by-two stack buffer overflow
 in function rpc_uaddr2sockaddr() of net/sunrpc/addr.c
Date: Wed, 11 Nov 2009 10:11:59 -0200
Message-ID: <20091111101159.72ad3014@gmail.com>
References: <bug-14546-10286@http.bugzilla.kernel.org/>
	<20091110152908.7558a471.akpm@linux-foundation.org>
	<967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
	<20091111075128.GA28323@evola>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Linux Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux NFS Mailing list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Patroklos Argyroudis <argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091111075128.GA28323@evola>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2009-11-11 Patroklos Argyroudis wrote:
> On Tue, Nov 10, 2009 at 06:38:05PM -0500, Chuck Lever wrote:
> > Why wouldn't you bump the size of the buffer by two as well?
> > Otherwise valid universal addresses that are RPCBIND_MAXUADDRLEN
> > bytes long will fail here.
> >=20
> > >	memcpy(buf, uaddr, uaddr_len);
>=20
> There is no need to increase the size of the buffer since the new
> check (if (uaddr_len > sizeof(buf) - 2)) will terminate the function
> in case the valid universal address is RPCBIND_MAXUADDRLEN bytes.

=46ailing to convert a valid address is incorrect and unexpected. What
Chuck meant is that since it is valid to have an address up to
RPCBIND_MAXUADDRLEN bytes long, the function should be able to work on
that, by having an internal buffer that allows for the extra "\n\0".

Cheers,
=46=C3=A1bio Oliv=C3=A9
--=20
ex sed lex awk yacc, e pluribus unix, amem
na matem=C3=A1tica das id=C3=A9ias, permuta =C3=A9 igual a adi=C3=A7=C3=
=A3o
e um debate inteligente implementa a multiplica=C3=A7=C3=A3o
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
