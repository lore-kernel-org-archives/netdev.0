From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] [NETFILTER]: Allow SYN+PSH as valid flag combination
Date: Sat, 12 Nov 2005 11:39:18 +0100
Message-ID: <20051112103918.GG10584@sunbeam.de.gnumonks.org>
References: <1131637730.14044.12.camel@quant> <437495E7.5050500@eurodev.net>
	<4374A369.6020308@trash.net>
	<20051111.114801.112784817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0MC1Z9bqFMhiUToQ"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@lists.netfilter.org, vlad@storewiz.com, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051111.114801.112784817.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--0MC1Z9bqFMhiUToQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11, 2005 at 11:48:01AM -0800, David S. Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 11 Nov 2005 14:58:01 +0100
>=20
> > Unfortunately this is unlikely to happen, and if Linux itself
> > accepts SYN|PSH, I don't see a reason why ip_conntrack shouldn't
> > as well.
>=20
> I totally agree.

Me, too.  However, we also need to update nf_conntrack now:


[NETFILTER] {ip,nf}_conntrack TCP: Accept SYN+PUSH like SYN

Some devices (e.g. Qlogic iSCSI HBA hardware like QLA4010 up to firmware
3.0.0.4) initiates TCP with SYN and PUSH flags set.

The Linux TCP/IP stack deals fine with that, but the connection tracking
code doesn't.

This patch alters TCP connection tracking to accept SYN+PUSH as a valid
flag combination.

Signed-off-by: Vlad Drukker <vlad@storewiz.com>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 933c4adfa34fbc151dd9908b2ce59335b22e6fe4
tree 041e7fc4116cd3b2774429cf8da9caee6e77a74b
parent 106c77b9b51b61bcd926ab5100761b2832791b74
author Harald Welte <laforge@netfilter.org> Sat, 12 Nov 2005 11:36:56 +0100
committer Harald Welte <laforge@netfilter.org> Sat, 12 Nov 2005 11:36:56 +0=
100

 net/ipv4/netfilter/ip_conntrack_proto_tcp.c |    1 +
 net/netfilter/nf_conntrack_proto_tcp.c      |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -814,6 +814,7 @@ static u8 tcp_valid_flags[(TH_FIN|TH_SYN
 {
 	[TH_SYN]			=3D 1,
 	[TH_SYN|TH_ACK]			=3D 1,
+	[TH_SYN|TH_PUSH]		=3D 1,
 	[TH_SYN|TH_ACK|TH_PUSH]		=3D 1,
 	[TH_RST]			=3D 1,
 	[TH_RST|TH_ACK]			=3D 1,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conn=
track_proto_tcp.c
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -779,6 +779,7 @@ static u8 tcp_valid_flags[(TH_FIN|TH_SYN
 {
 	[TH_SYN]			=3D 1,
 	[TH_SYN|TH_ACK]			=3D 1,
+	[TH_SYN|TH_PUSH]		=3D 1,
 	[TH_SYN|TH_ACK|TH_PUSH]		=3D 1,
 	[TH_RST]			=3D 1,
 	[TH_RST|TH_ACK]			=3D 1,

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--0MC1Z9bqFMhiUToQ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDdcZWXaXGVTD0i/8RAtCjAJ4gHEFYwSzUbUSIPJzG688XqLo5HgCdEfFV
2K11KLY9K9vU/Z2n/yXecSY=
=2pkP
-----END PGP SIGNATURE-----

--0MC1Z9bqFMhiUToQ--
