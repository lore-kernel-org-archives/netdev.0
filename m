From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: nfs client hang
Date: Tue, 27 Jul 2010 14:21:16 +0200
Message-ID: <1280233276.2827.175.camel@edumazet-laptop>
References: <99613C19B13C5D40914FB8930657FA9303365708DE@uk-ex-mbx1.terastack.bluearc.com>
	 <4C4E89D4.8040607@bluearc.com>
	 <ABFC24E4C13D81489F7F624E14891C8607DDF8D1E4@uk-ex-mbx1.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linux Kernel Mailing List (linux-kernel@vger.kernel.org)"
	<linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	netdev <netdev@vger.kernel.org>
To: Andy Chittenden <andyc@bluearc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59468 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab0G0MVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 08:21:21 -0400
In-Reply-To: <ABFC24E4C13D81489F7F624E14891C8607DDF8D1E4@uk-ex-mbx1.terastack.bluearc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 juillet 2010 =C3=A0 11:53 +0100, Andy Chittenden a =C3=A9cr=
it :
> > >> IE the client starts a connection and then closes it again witho=
ut sending data.
> > > Once this happens, here's some rpcdebug info for the rpc module u=
sing 2.6.34.1 kernel:
> > >
> > > ... lots of the following nfsv3 WRITE requests:
> > > [ 7670.026741] 57793 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026759] 57794 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026778] 57795 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026797] 57796 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026815] 57797 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026834] 57798 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026853] 57799 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026871] 57800 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026890] 57801 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7670.026909] 57802 0001    -11 ffff88012e32b000   (null)       =
 0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
> > > [ 7680.520042] RPC:       worker connecting xprt ffff88013e62d800=
 via tcp to 10.1.6.102 (port 2049)
> > > [ 7680.520066] RPC:       ffff88013e62d800 connect status 99 conn=
ected 0 sock state 7
> > > [ 7680.520074] RPC: 33550 __rpc_wake_up_task (now 4296812426)
> > > [ 7680.520079] RPC: 33550 disabling timer
> > > [ 7680.520084] RPC: 33550 removed from queue ffff88013e62db20 "xp=
rt_pending"
> > > [ 7680.520089] RPC:       __rpc_wake_up_task done
> > > [ 7680.520094] RPC: 33550 __rpc_execute flags=3D0x1
> > > [ 7680.520098] RPC: 33550 xprt_connect_status: retrying
> > > [ 7680.520103] RPC: 33550 call_connect_status (status -11)
> > > [ 7680.520108] RPC: 33550 call_transmit (status 0)
> > > [ 7680.520112] RPC: 33550 xprt_prepare_transmit
> > > [ 7680.520118] RPC: 33550 rpc_xdr_encode (status 0)
> > > [ 7680.520123] RPC: 33550 marshaling UNIX cred ffff88012e002300
> > > [ 7680.520130] RPC: 33550 using AUTH_UNIX cred ffff88012e002300 t=
o wrap rpc data
> > > [ 7680.520136] RPC: 33550 xprt_transmit(32920)
> > > [ 7680.520145] RPC:       xs_tcp_send_request(32920) =3D -32
> > > [ 7680.520151] RPC:       xs_tcp_state_change client ffff88013e62=
d800...
> > > [ 7680.520156] RPC:       state 7 conn 0 dead 0 zapped 1
>=20
> > I changed that debug to output sk_shutdown too. That has a value of=
 2=20
> > (IE SEND_SHUTDOWN). Looking at tcp_sendmsg(), I see this:
>=20
> >          err =3D -EPIPE;
> >          if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
> >                  goto out_err;
>=20
> > which correlates with the trace "xs_tcp_send_request(32920) =3D -32=
". So,=20
> > this looks like a problem in the sockets/tcp layer. The rpc layer i=
ssues=20
> > a shutdown and then reconnects using the same socket. So either=20
> > sk_shutdown needs zeroing once the shutdown completes or should be=20
> > zeroed on subsequent connect. The latter sounds safer.
>=20
> This patch for 2.6.34.1 fixes the issue:
>=20
> --- /home/company/software/src/linux-2.6.34.1/net/ipv4/tcp_output.c  =
   2010-07-27 08:46:46.917000000 +0100
> +++ net/ipv4/tcp_output.c       2010-07-27 09:19:16.000000000 +0100
> @@ -2522,6 +2522,13 @@
>         struct tcp_sock *tp =3D tcp_sk(sk);
>         __u8 rcv_wscale;
> =20
> +       /* clear down any previous shutdown attempts so that
> +        * reconnects on a socket that's been shutdown leave the
> +        * socket in a usable state (otherwise tcp_sendmsg() returns
> +        * -EPIPE).
> +        */
> +       sk->sk_shutdown =3D 0;
> +
>         /* We'll fix this up when we get a response from the other en=
d.
>          * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
>          */
>=20
> As I mentioned in my first message, we first saw this issue in 2.6.32=
 as supplied by debian (linux-image-2.6.32-5-amd64 Version: 2.6.32-17).=
 It looks like the same patch would fix the problem there too.
>=20

CC netdev

This reminds me a similar problem we had in the past, fixed with commit
1fdf475a (tcp: tcp_disconnect() should clear window_clamp)

But tcp_disconnect() already clears sk->sk_shutdown

If NFS calls tcp_disconnect(), then shutdown(), there is a problem.

Maybe xs_tcp_shutdown() should make some sanity tests ?

=46ollowing sequence is legal, and your patch might break it.

fd =3D socket(...);
shutdown(fd, SHUT_WR);
=2E..
connect(fd, ...);



