From: Harald Welte <laforge@netfilter.org>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 14:30:26 +0200
Message-ID: <20090412123026.GL19172@prithivi.gnumonks.org>
References: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr> <20090410.230016.176733137.davem@davemloft.net> <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com> <alpine.DEB.1.10.0904111751430.28893@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hLTC+yGFJlatjToQ"
Cc: Kyle Moffett <kyle@moffetthome.net>,
	David Miller <davem@davemloft.net>, jengelh@medozas.de,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: david@lang.hm
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904111751430.28893@asgard.lang.hm>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hLTC+yGFJlatjToQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Sat, Apr 11, 2009 at 05:54:41PM -0700, david@lang.hm wrote:
>> Almost all of the standard firewall tools (such as shorewall, etc) are
>> already using iptables-restore command to load firewall rules,
>> primarily because using separate iptables commands was *already* way
>> too slow.  There's also the serious race-condition of doing a firewall
>> restart that way where you only have half your rules loaded for a bit.
>> The "iptables" command is fine for fiddling around with the command
>> line and making minor tweaks, but it simply doesn't cut it for
>> large-scale rules.
>
> what are the userspace level tools that I am supposed to use in place of =
=20
> my current process? (which is to have a script that 1. stops traffic, 2. =
=20
> executes the iptables commands to create the rules that I want, then 3. =
=20
> enables traffic)
>
> iptables-restore only works if you are actually restoring the old set of =
=20
> rules. if you need to change the rules that doesn't work.

That's what I implemented as "iptables-restore --noflush" a number of years
ago. It doesn't flush the current uleset and swaps in a new one, but=20
reads the current rules from kernel, applies any number of changes and swaps
the new ruleset in.

The syntax of iptables-restore is almost identical to iptables commands, you
just specify the table in a different way.  So you would just create your
desired changes in that format, and echo that into iptables-restore.  If it=
's
an entire new ruleset, you use no '--noflush' and it does automatic flushing
of all old rules.  If your stdin-file contains only incremental changes, you
use --noflush.

In the netfilter project, we knew for many years that the 'swap the entire
table atomically in' is a bad design choice.  This is what various develope=
rs
have been trying to address at different times, and which finally resulted
in the nftables implementation of Patrick McHardy.  So for the mid- to long
term there is a clear design that moves away from that.

But so far, we have to live with the API and its semantics.  iptables users=
pace
has been improved a number of times, and things like iptables-restore with =
or
without --noflush can be used as an intermediate solution - and have been u=
sed
by many systems out there.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--hLTC+yGFJlatjToQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFJ4d7iXaXGVTD0i/8RAsIbAKCEurTCifbQxxy9HxXJkh9fkGvCDgCfYmiG
j581fDfdXd0kho8vp56EtqM=
=ruDw
-----END PGP SIGNATURE-----

--hLTC+yGFJlatjToQ--
