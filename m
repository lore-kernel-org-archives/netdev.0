From: Eric Leblond <eric@inl.fr>
Subject: Re: linux-next: net tree build warnings
Date: Thu, 26 Mar 2009 08:50:19 +0100
Message-ID: <1238053819.13879.4.camel@ice-age>
References: <20090326173713.ee63b803.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-1mI39PDzsM3cjtQWIKXI"
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-next@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326173713.ee63b803.sfr@canb.auug.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1mI39PDzsM3cjtQWIKXI
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi Stephen,

Le jeudi 26 mars 2009 =E0 17:37 +1100, Stephen Rothwell a =E9crit :
> Hi Dave,
>=20
> Today's linux-next build (x86_64 allmodconfig) produced these warnings:
>=20
> net/bridge/netfilter/ebt_log.c: In function 'ebt_log_init':
> net/bridge/netfilter/ebt_log.c:230: warning: passing argument 2 of 'nf_lo=
g_register' discards qualifiers from pointer target type
> net/bridge/netfilter/ebt_log.c: In function 'ebt_log_fini':
> net/bridge/netfilter/ebt_log.c:236: warning: passing argument 1 of 'nf_lo=
g_unregister' discards qualifiers from pointer target type
> net/bridge/netfilter/ebt_ulog.c: In function 'ebt_ulog_init':
> net/bridge/netfilter/ebt_ulog.c:317: warning: passing argument 2 of 'nf_l=
og_register' discards qualifiers from pointer target type
> net/bridge/netfilter/ebt_ulog.c: In function 'ebt_ulog_fini':
> net/bridge/netfilter/ebt_ulog.c:327: warning: passing argument 1 of 'nf_l=
og_unregister' discards qualifiers from pointer target type

Thanks a lot for pointing this. I stupidely forgot to build this module
during my testing.

I've made the necessary modifications and a patch fixing this will
follow this mail.

Doing some testing of the ebt_ulog module, I've found some problems. One
of them was the following messages:

sys_init_module: 'ebt_ulog'->init suspiciously returned 1, it should
follow 0/-E convention
sys_init_module: loading module anyway...
Pid: 2334, comm: modprobe Not tainted 2.6.29-rc5edenwall0-00883-g199e57b
#146
Call Trace:
 [<c0441b81>] ? printk+0xf/0x16
 [<c02311af>] sys_init_module+0x107/0x186
 [<c0202cfa>] syscall_call+0x7/0xb

A patch fixing this will also follow.

BR,
--=20
Eric Leblond <eric@inl.fr>
INL: http://www.inl.fr/
NuFW: http://www.nufw.org/

--=-1mI39PDzsM3cjtQWIKXI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Ceci est une partie de message
 =?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJyzO3nxA7CdMWjzIRAu6pAJ9Qm5sP+EjjGWtpnF/IPYqMP+L2zgCfWEBc
VQxY21M4b9mhmvJXN/w84iY=
=HLru
-----END PGP SIGNATURE-----

--=-1mI39PDzsM3cjtQWIKXI--

