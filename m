From: Dan Merillat <dmerillat@sequiam.com>
Subject: Re: Fw: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR
Date: Thu, 9 Oct 2003 13:03:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031009170350.GA1582@chaos.ao.net>
References: <20031008133345.49f71991.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031008133345.49f71991.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 08 Oct 2003, David S. Miller wrote:

> Arnaldo, I think this is another piece of fallout
> from the struct sock splitup you did ages ago.
>=20
> I think it's dereferencing inet_sk(sk) for a time-wait
> socket, so we probably need a TCP_TIME_WAIT test plus
> some additional logic here?  Better check tcp_ipv6.c too.

Found some more on this, it's been entered into the kernel bug-tracker

http://bugme.osdl.org/show_bug.cgi?id=3D1271

He managed to get an oops out of his:

Unable to handle kernel NULL pointer dereference at virtual address 00000049
 printing eip:
c030b346
*pde =3D 00000000
Oops: 0000 [#1]
CPU:    1
EIP:    0060:[<c030b346>]    Not tainted
EFLAGS: 00010246
EIP is at tcp_v4_get_port+0x3c6/0x3e0
eax: 00000000   ebx: f74ff380   ecx: f667ff40   edx: f667ff50
esi: 00000002   edi: 00002151   ebp: f66097c0   esp: f6b0be68
ds: 007b   es: 007b   ss: 0068
Process perl (pid: 3433, threadinfo=3Df6b0a000 task=3Df6b0d900)
Stack: 00000000 00000000 00000000 f66270d0 00000000 00000000 00000001 f6609=
908=20
       00000000 00000000 00000000 00000001 f7c90a88 f66097c0 ffffffea f6609=
908=20
       f6b0bee8 c031f215 f66097c0 00002151 c02d568d 00000003 21511818 f6612=
740=20
Call Trace:
 [<c031f215>] inet_bind+0x1d5/0x300
 [<c02d568d>] move_addr_to_kernel+0x8d/0xa0
 [<c02d6d8b>] sys_bind+0x7b/0xb0
 [<c011c11c>] do_page_fault+0x23c/0x44f
 [<c02d59dc>] sockfd_lookup+0x1c/0x80
 [<c02d74d8>] sys_setsockopt+0x78/0xc0
 [<c02d7be8>] sys_socketcall+0xc8/0x2b0
 [<c01095d9>] sysenter_past_esp+0x52/0x71

Code: 0f b6 40 49 24 20 84 c0 75 97 eb 89 89 14 24 e8 06 51 e1 ff=20
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing



--gKMricLos+KVdGMg
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----

iD8DBQE/hZT2kycScExRgsgRAnXrAJ9ttKjS7RuZCSWpKpx4aYBXkRy/KwCfSQYA
ngJBt1xWL4yLp0PU4a/dHjY=
=RCwu
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
