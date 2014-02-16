From: John <da_audiophile@yahoo.com>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Sat, 15 Feb 2014 18:09:46 -0800 (PST)
Message-ID: <1392516586.24492.YahooMailNeo@web140006.mail.bf1.yahoo.com>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com> <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com> <20140215203015.GA4528@pd.tnic> <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com> <20140215232508.GB4508@pd.tnic>
Reply-To: John <da_audiophile@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"mlindner@marvell.com" <mlindner@marvell.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Borislav Petkov <bp@alien8.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm30-vm0.bullet.mail.bf1.yahoo.com ([98.139.213.126]:42198 "EHLO
	nm30-vm0.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752449AbaBPCJr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Feb 2014 21:09:47 -0500
In-Reply-To: <20140215232508.GB4508@pd.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





----- Original Message -----
> From: Borislav Petkov <>
> Sent: Saturday, February 15, 2014 6:25 PM
> Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
>=20
> On Sat, Feb 15, 2014 at 01:04:22PM -0800, John wrote:
>>  Thanks for the reply, Boris. =A0The .config is unmodified
>>  from the Arch Distro default for 3.13.3-1 which can be found
>>  here:=A0http://pastebin.com/LPGZ8ZqA
>=20
> Yep, it is that struct net *net argument to put_pipe_version() which =
is NULL:
>=20
> =A0 12:=A0  55=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 push=A0  %e=
bp
> =A0 13:=A0  89 e5=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0  mov=A0 =A0 %esp=
,%ebp
> =A0 15:=A0  56=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 push=A0  %e=
si
> =A0 16:=A0  53=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 push=A0  %e=
bx
> =A0 17:=A0  3e 8d 74 26 00=A0 =A0 =A0 =A0 =A0 lea=A0 =A0 %ds:0x0(%esi=
,%eiz,1),%esi
> =A0 1c:=A0  8b 1d 28 e9 a3 f8=A0 =A0 =A0  mov=A0 =A0 0xf8a3e928,%ebx
> =A0 22:=A0  89 c6=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0  mov=A0 =A0 %eax=
,%esi
> =A0 24:=A0  e8 59 64 5f c8=A0 =A0 =A0 =A0 =A0 call=A0  0xc85f6482
> =A0 29:=A0  85 db=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0  test=A0  %ebx,%=
ebx
> =A0 2b:*=A0 8b 86 58 08 00 00=A0 =A0 =A0  mov=A0 =A0 0x858(%esi),%eax=
=A0 =A0 =A0 =A0  <-- trapping=20
> instruction
>=20
> put_pipe_version:
> =A0=A0=A0 pushl=A0=A0=A0 %ebp=A0=A0=A0 #
> =A0=A0=A0 movl=A0=A0=A0 %esp, %ebp=A0=A0=A0 #,
> =A0=A0=A0 pushl=A0=A0=A0 %esi=A0=A0=A0 #
> =A0=A0=A0 pushl=A0=A0=A0 %ebx=A0=A0=A0 #
> =A0=A0=A0 call=A0=A0=A0 mcount
> =A0=A0=A0 movl=A0=A0=A0 sunrpc_net_id, %ebx=A0=A0=A0 # sunrpc_net_id,=
 sunrpc_net_id.130
> =A0=A0=A0 movl=A0=A0=A0 %eax, %esi=A0=A0=A0 # net, net
> =A0=A0=A0 call=A0=A0=A0 __rcu_read_lock=A0=A0=A0 #
> =A0=A0=A0 testl=A0=A0=A0 %ebx, %ebx=A0=A0=A0 # sunrpc_net_id.130
> =A0=A0=A0 movl=A0=A0=A0 2136(%esi), %eax=A0=A0=A0 # MEM[(struct net_g=
eneric * const *)net_4(D) +=20
> 2136B], ng <-- trapping insn
>=20
>=20
> =A0=A0=A0 [ 137.689996] ESI: 00000000 EDI: f56efc00 EBP: f568fee8 ESP=
: f568fee0
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0  ^^^^^^^^
>=20
> Here's the c/asm interleaved version:
>=20
> static void put_pipe_version(struct net *net)
> {
> =A0 =A0  d80:=A0 =A0 =A0  55=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 push=A0  %ebp
> =A0 =A0  d81:=A0 =A0 =A0  89 e5=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0  m=
ov=A0 =A0 %esp,%ebp
> =A0 =A0  d83:=A0 =A0 =A0  56=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 push=A0  %esi
> =A0 =A0  d84:=A0 =A0 =A0  53=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 push=A0  %ebx
> =A0 =A0  d85:=A0 =A0 =A0  e8 fc ff ff ff=A0 =A0 =A0 =A0 =A0 call=A0  =
d86 <put_pipe_version+0x6>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 d86: R_386_PC32 mcoun=
t
> =A0 =A0 =A0 =A0 struct sunrpc_net *sn =3D net_generic(net, sunrpc_net=
_id);
> =A0 =A0  d8a:=A0 =A0 =A0  8b 1d 00 00 00 00=A0 =A0 =A0  mov=A0 =A0 0x=
0,%ebx
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 d8c: R_386_32=A0  sun=
rpc_net_id
> =A0 =A0 =A0 =A0 spin_unlock(&pipe_version_lock);
> =A0 =A0 =A0 =A0 return ret;
> }
>=20
> static void put_pipe_version(struct net *net)
> {
> =A0 =A0  d90:=A0 =A0 =A0  89 c6=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0  m=
ov=A0 =A0 %eax,%esi
> * block, but only when acquiring spinlocks that are subject to priori=
ty
> * inheritance.
> */
> static inline void rcu_read_lock(void)
> {
> =A0 =A0 =A0 =A0 __rcu_read_lock();
> =A0 =A0  d92:=A0 =A0 =A0  e8 fc ff ff ff=A0 =A0 =A0 =A0 =A0 call=A0  =
d93 <put_pipe_version+0x13>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 d93: R_386_PC32 __rcu=
_read_lock
> =A0 =A0 =A0 =A0 struct net_generic *ng;
> =A0 =A0 =A0 =A0 void *ptr;
>=20
> =A0 =A0 =A0 =A0 rcu_read_lock();
> =A0 =A0 =A0 =A0 ng =3D rcu_dereference(net->gen);
> =A0 =A0 =A0 =A0 BUG_ON(id =3D=3D 0 || id > ng->len);
> =A0 =A0  d97:=A0 =A0 =A0  85 db=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0  t=
est=A0  %ebx,%ebx
> {
> =A0 =A0 =A0 =A0 struct net_generic *ng;
> =A0 =A0 =A0 =A0 void *ptr;
>=20
> =A0 =A0 =A0 =A0 rcu_read_lock();
> =A0 =A0 =A0 =A0 ng =3D rcu_dereference(net->gen);
> =A0 =A0  d99:=A0 =A0 =A0  8b 86 58 08 00 00=A0 =A0 =A0  mov=A0 =A0 0x=
858(%esi),%eax=A0=A0=A0 =A0=A0=A0 =A0=A0=A0=20
> <-- trapping insn
>=20
>=20
> I guess you could avoid the crash if you did
>=20
> =A0=A0=A0 if (!net)
> =A0=A0=A0 =A0=A0=A0 return;
>=20
> in put_pipe_version() but this hardly is the right solution. Someone
> else has to make sense of this thing, not me. :-)
>=20
> HTH.


I copy someone you cc'ed on this understands it. =A0I have no idea what=
 you wrote :)
