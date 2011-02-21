From: Andrian Nord <nightnord-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Huge ammount of invalid checksum packets on macvlan
Date: Mon, 21 Feb 2011 20:39:45 +0300
Message-ID: <20110221173945.GA8588@nord.niifaq.ru>
References: <20110221150710.GA5651@nord.niifaq.ru> <4D6282DB.2080204@free.fr>
	<20110221153421.GA6602@nord.niifaq.ru> <4D628DC3.9000400@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9010291660694955941=="
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Return-path: <lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <4D628DC3.9000400-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=lxc-users>
List-Post: <mailto:lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============9010291660694955941==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Content-Disposition: inline


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 21, 2011 at 05:07:31PM +0100, Daniel Lezcano wrote:
> IMO, the checksum is not needed for the virtual macvlan devices, hence=20
Well, maybe then I've made a horrible mistake of asking the wrong
question. It's not a bad checksums that are wondering me, but very poor
network traffic performance: I'm getting about ~25kbps of
/dev/zero-to-/dev/null copy via netcat between hosts and mysql queries
=66rom container other than mysql's are horribly laggy.

Strangely enough - while there is such bug on both systems, they are
behaving differently.

First system (router):
   eth1          eth0       dummy0
|----|------------|-----------|-----|   macvlans        |------------|
|  macvlan "lan"  |           |-------------------------| containers |
|   /  \          |           |     |                   | -----------|
|--|---|----------|-----------|-----|                   =20
   |   |          |           | macvlan                  =20
   |   |     |----------------|------|
  ---  |     |  eth0  eth1   eth2    | Router-container
  LAN  |     |         |             |
  ---  \---------------/             |
             |-----------------------|


And bug appears much less when copying from container to container, or
=66rom container to HN (but still noticeable, especially in mysql queries),
but it's seen very well when copying from LAN to container. netcat copy
transfer rate shows enormous ~300 Mbps.
/proc/net/dev show many transfer errors but 0 receive errors.

Second system (server):
   eth0         eth1       dummy0
|----------------------------|---------------|
|             no carrier     |-macvlan "lxc" |
|----------------------------|---------------|
                             |
		|---------------------------|
		|        containers         |
		|---------------------------|

We can't link macvlans on eth1, as it has no carrier and macvlans are
not working in this case. Here bug is seen very well, even in
transferring packets from container to container (netcat copy transfer
rate is ~40kbps on this system).
/proc/net/dev show may errors in both directions.

First system is slightly more powerful, but difference in
between-container performance is just too big. Also, tcpdump on both
system reports kernel-dropped packets in great amount.

P.S. netcat copy is:
lxc1) nc6 -l -p 12345 > /dev/null
lxc2) dd if=3D/dev/zero | nc6 lxc1 12345

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1io2EACgkQZAqeN5KgLbSbIACdHnGpJGZKPbKWovFWN4K2T4vz
rFwAoIelzE+1cJXuRzkQOCOSzifoxoIq
=Hapb
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--


--===============9010291660694955941==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
The ultimate all-in-one performance toolkit: Intel(R) Parallel Studio XE:
Pinpoint memory and threading errors before they happen.
Find and fix more than 250 security defects in the development cycle.
Locate bottlenecks in serial and parallel code that limit performance.
http://p.sf.net/sfu/intel-dev2devfeb
--===============9010291660694955941==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============9010291660694955941==--
