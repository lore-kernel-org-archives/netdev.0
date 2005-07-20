From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 3/*] re-add NFC_ defines
Date: Wed, 20 Jul 2005 09:31:37 -0400
Message-ID: <20050720133137.GD4077@rama>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tSiBuZsJmMXpnp7T"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
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


--tSiBuZsJmMXpnp7T
Content-Type: multipart/mixed; boundary="jaoouwwPWoQSJZYp"
Content-Disposition: inline


--jaoouwwPWoQSJZYp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,=20

we have to re-add the NFC_ defines to the header files, otherwise old
userspace code (such as old versions of the iptables program) will fail
to compile :(

Please apply to your 2.6.14 tree, thanks!


--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--jaoouwwPWoQSJZYp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03-nfc_defines.patch"
Content-Transfer-Encoding: quoted-printable

re-add NFC_* defines, since old usersapce programs need those definitions.
So we'll have to keep them, even if they're totally useless.
They're now in an "#ifndef __KERNEL__" section though.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 2e301df4f0b9c9c0faf68e5b42d2f59d912c148f
tree 0aa034b16808c0eb13ea49d31c268d5d9a70f4d1
parent 41a00086e4c896f92c8a29f8e2e5f6d893118e77
author laforge <laforge@netfilter.org> Mi, 20 Jul 2005 09:15:03 -0400
committer laforge <laforge@netfilter.org> Mi, 20 Jul 2005 09:15:03 -0400

 include/linux/netfilter.h        |    8 ++++++++
 include/linux/netfilter_decnet.h |   13 +++++++++++++
 include/linux/netfilter_ipv4.h   |   31 +++++++++++++++++++++++++++++++
 include/linux/netfilter_ipv6.h   |   33 +++++++++++++++++++++++++++++++++
 4 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -21,6 +21,14 @@
 #define NF_STOP 5
 #define NF_MAX_VERDICT NF_STOP
=20
+/* only for userspace compatibility */
+#ifndef __KERNEL__
+/* Generic cache responses from hook functions.
+   <=3D 0x2000 is used for protocol-flags. */
+#define NFC_UNKNOWN 0x4000
+#define NFC_ALTERED 0x8000
+#endif
+
 #ifdef __KERNEL__
 #include <linux/config.h>
 #ifdef CONFIG_NETFILTER
diff --git a/include/linux/netfilter_decnet.h b/include/linux/netfilter_dec=
net.h
--- a/include/linux/netfilter_decnet.h
+++ b/include/linux/netfilter_decnet.h
@@ -9,6 +9,19 @@
=20
 #include <linux/netfilter.h>
=20
+/* only for userspace compatibility */
+#ifndef __KERNEL__
+/* IP Cache bits. */
+/* Src IP address. */
+#define NFC_DN_SRC		0x0001
+/* Dest IP address. */
+#define NFC_DN_DST		0x0002
+/* Input device. */
+#define NFC_DN_IF_IN		0x0004
+/* Output device. */
+#define NFC_DN_IF_OUT		0x0008
+#endif /* ! __KERNEL__ */
+
 /* DECnet Hooks */
 /* After promisc drops, checksum checks. */
 #define NF_DN_PRE_ROUTING	0
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -8,6 +8,37 @@
 #include <linux/config.h>
 #include <linux/netfilter.h>
=20
+/* only for userspace compatibility */
+#ifndef __KERNEL__
+/* IP Cache bits. */
+/* Src IP address. */
+#define NFC_IP_SRC		0x0001
+/* Dest IP address. */
+#define NFC_IP_DST		0x0002
+/* Input device. */
+#define NFC_IP_IF_IN		0x0004
+/* Output device. */
+#define NFC_IP_IF_OUT		0x0008
+/* TOS. */
+#define NFC_IP_TOS		0x0010
+/* Protocol. */
+#define NFC_IP_PROTO		0x0020
+/* IP options. */
+#define NFC_IP_OPTIONS		0x0040
+/* Frag & flags. */
+#define NFC_IP_FRAG		0x0080
+
+/* Per-protocol information: only matters if proto match. */
+/* TCP flags. */
+#define NFC_IP_TCPFLAGS		0x0100
+/* Source port. */
+#define NFC_IP_SRC_PT		0x0200
+/* Dest port. */
+#define NFC_IP_DST_PT		0x0400
+/* Something else about the proto */
+#define NFC_IP_PROTO_UNKNOWN	0x2000
+#endif /* ! __KERNEL__ */
+
 /* IP Hooks */
 /* After promisc drops, checksum checks. */
 #define NF_IP_PRE_ROUTING	0
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -10,6 +10,39 @@
=20
 #include <linux/netfilter.h>
=20
+/* only for userspace compatibility */
+#ifndef __KERNEL__
+/* IP Cache bits. */
+/* Src IP address. */
+#define NFC_IP6_SRC              0x0001
+/* Dest IP address. */
+#define NFC_IP6_DST              0x0002
+/* Input device. */
+#define NFC_IP6_IF_IN            0x0004
+/* Output device. */
+#define NFC_IP6_IF_OUT           0x0008
+/* TOS. */
+#define NFC_IP6_TOS              0x0010
+/* Protocol. */
+#define NFC_IP6_PROTO            0x0020
+/* IP options. */
+#define NFC_IP6_OPTIONS          0x0040
+/* Frag & flags. */
+#define NFC_IP6_FRAG             0x0080
+
+
+/* Per-protocol information: only matters if proto match. */
+/* TCP flags. */
+#define NFC_IP6_TCPFLAGS         0x0100
+/* Source port. */
+#define NFC_IP6_SRC_PT           0x0200
+/* Dest port. */
+#define NFC_IP6_DST_PT           0x0400
+/* Something else about the proto */
+#define NFC_IP6_PROTO_UNKNOWN    0x2000
+#endif /* ! __KERNEL__ */
+
+
 /* IP6 Hooks */
 /* After promisc drops, checksum checks. */
 #define NF_IP6_PRE_ROUTING	0

--jaoouwwPWoQSJZYp--

--tSiBuZsJmMXpnp7T
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC3lI4XaXGVTD0i/8RAqk5AJ9f9YJPWAODr3iJm883+CtANp+S/QCgjzfD
Us+yXb5tYCo5qlzfsE7p0Qo=
=7J2/
-----END PGP SIGNATURE-----

--tSiBuZsJmMXpnp7T--
