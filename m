From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
Date: Thu, 30 Jun 2016 13:17:47 +0000
Message-ID: <C44AFFBB-EF40-4B22-8B45-7817EB7276E3@primarydata.com>
References: <20160630085950.61e5c7e0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Layton <jlayton@poochiereds.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Schumaker Anna <anna.schumaker@netapp.com>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
	"Linux Network Devel Mailing List" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	Fields Bruce <bfields@fieldses.org>
To: Rostedt Steven <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160630085950.61e5c7e0@gandalf.local.home>
Content-Language: en-US
Content-ID: <5C4B0D82C3083343B79D3A034F3E0BEF@namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Jun 30, 2016, at 08:59, Steven Rostedt <rostedt@goodmis.org> wrote=
:
>=20
> [ resending as a new email, as I'm assuming people do not sort their
>  INBOX via last email on thread, thus my last email is sitting in the
>  bottom of everyone's INBOX ]
>=20
> I've hit this again. Not sure when it started, but I applied my old
> debug trace_printk() patch (attached) and rebooted (4.5.7). I just
> tested the latest kernel from Linus's tree (from last nights pull), a=
nd
> it still gives me the problem.
>=20
> Here's the trace I have:
>=20
>    kworker/3:1H-134   [003] ..s.    61.036129: inet_csk_get_port: snu=
m 805
>    kworker/3:1H-134   [003] ..s.    61.036135: <stack trace>
> =3D> sched_clock
> =3D> inet_addr_type_table
> =3D> security_capable
> =3D> inet_bind
> =3D> xs_bind
> =3D> release_sock
> =3D> sock_setsockopt
> =3D> __sock_create
> =3D> xs_create_sock.isra.19
> =3D> xs_tcp_setup_socket
> =3D> process_one_work
> =3D> worker_thread
> =3D> worker_thread
> =3D> kthread
> =3D> ret_from_fork
> =3D> kthread =20
>    kworker/3:1H-134   [003] ..s.    61.036136: inet_bind_hash: add 80=
5
>    kworker/3:1H-134   [003] ..s.    61.036138: <stack trace>
> =3D> inet_csk_get_port
> =3D> sched_clock
> =3D> inet_addr_type_table
> =3D> security_capable
> =3D> inet_bind
> =3D> xs_bind
> =3D> release_sock
> =3D> sock_setsockopt
> =3D> __sock_create
> =3D> xs_create_sock.isra.19
> =3D> xs_tcp_setup_socket
> =3D> process_one_work
> =3D> worker_thread
> =3D> worker_thread
> =3D> kthread
> =3D> ret_from_fork
> =3D> kthread =20
>    kworker/3:1H-134   [003] ....    61.036139: xs_bind: RPC:       xs=
_bind 4.136.255.255:805: ok (0)
>    kworker/3:1H-134   [003] ....    61.036140: xs_tcp_setup_socket: R=
PC:       worker connecting xprt ffff880407eca800 via tcp to 192.168.23=
=2E22 (port 43651)
>    kworker/3:1H-134   [003] ....    61.036162: xs_tcp_setup_socket: R=
PC:       ffff880407eca800 connect status 115 connected 0 sock state 2
>          <idle>-0     [001] ..s.    61.036450: xs_tcp_state_change: R=
PC:       xs_tcp_state_change client ffff880407eca800...
>          <idle>-0     [001] ..s.    61.036452: xs_tcp_state_change: R=
PC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
>    kworker/1:1H-136   [001] ....    61.036476: xprt_connect_status: R=
PC:    43 xprt_connect_status: retrying
>    kworker/1:1H-136   [001] ....    61.036478: xprt_prepare_transmit:=
 RPC:    43 xprt_prepare_transmit
>    kworker/1:1H-136   [001] ....    61.036479: xprt_transmit: RPC:   =
 43 xprt_transmit(72)
>    kworker/1:1H-136   [001] ....    61.036486: xs_tcp_send_request: R=
PC:       xs_tcp_send_request(72) =3D 0
>    kworker/1:1H-136   [001] ....    61.036487: xprt_transmit: RPC:   =
 43 xmit complete
>          <idle>-0     [001] ..s.    61.036789: xs_tcp_data_ready: RPC=
:       xs_tcp_data_ready...
>    kworker/1:1H-136   [001] ....    61.036798: xs_tcp_data_recv: RPC:=
       xs_tcp_data_recv started
>    kworker/1:1H-136   [001] ....    61.036799: xs_tcp_data_recv: RPC:=
       reading TCP record fragment of length 24
>    kworker/1:1H-136   [001] ....    61.036799: xs_tcp_data_recv: RPC:=
       reading XID (4 bytes)
>    kworker/1:1H-136   [001] ....    61.036800: xs_tcp_data_recv: RPC:=
       reading request with XID 2f4c3f88
>    kworker/1:1H-136   [001] ....    61.036800: xs_tcp_data_recv: RPC:=
       reading CALL/REPLY flag (4 bytes)
>    kworker/1:1H-136   [001] ....    61.036801: xs_tcp_data_recv: RPC:=
       read reply XID 2f4c3f88
>    kworker/1:1H-136   [001] ..s.    61.036801: xs_tcp_data_recv: RPC:=
       XID 2f4c3f88 read 16 bytes
>    kworker/1:1H-136   [001] ..s.    61.036802: xs_tcp_data_recv: RPC:=
       xprt =3D ffff880407eca800, tcp_copied =3D 24, tcp_offset =3D 24,=
 tcp_reclen =3D 24
>    kworker/1:1H-136   [001] ..s.    61.036802: xprt_complete_rqst: RP=
C:    43 xid 2f4c3f88 complete (24 bytes received)
>    kworker/1:1H-136   [001] ....    61.036803: xs_tcp_data_recv: RPC:=
       xs_tcp_data_recv done
>    kworker/1:1H-136   [001] ....    61.036812: xprt_release: RPC:    =
43 release request ffff88040b270800
>=20
>=20
> # unhide-tcp=20
> Unhide-tcp 20130526
> Copyright =A9 2013 Yago Jesus & Patrick Gouin
> License GPLv3+ : GNU GPL version 3 or later
> http://www.unhide-forensics.info
> Used options:=20
> [*]Starting TCP checking
>=20
> Found Hidden port that not appears in ss: 805
>=20

What is a =93Hidden port that not appears in ss: 805=94, and what does =
this report mean? Are we failing to close a socket?

Cheers
  Trond
