From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/3] decnet: Move to staging
Date: Tue, 23 Nov 2010 03:51:53 +0000
Message-ID: <1290484313.6770.1328.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org, Debian
 kernel maintainers <debian-kernel@lists.debian.org>
To: David Miller <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
Resent-Message-ID: <L14j6eGMF9K.A.gGC.xpz6MB@liszt>
List-URL: <http://lists.debian.org/debian-kernel/>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Recent review has revealed several bugs in obscure protocol
implementations that can be exploited by local users for denial of
service or privilege escalation.

The decnet protocol (PF_DECnet) is unmaintained.  Since 2.6.12-rc2 the
only changes appear to be adjustments for net API changes and fixes
for bugs found by inspection.

This protocol generally should not be enabled by distributions, since
the cost of a security flaw affecting all installed systems presumably
outweighs the benefit to the few (if any) legitimate users.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/staging/Kconfig |    2 ++
 net/Kconfig             |    2 --
 net/decnet/Kconfig      |    3 +++
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 5eafdf4..dd94cb2 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -175,5 +175,7 @@ source "drivers/staging/intel_sst/Kconfig"
=20
 source "drivers/staging/speakup/Kconfig"
=20
+source "net/decnet/Kconfig"
+
 endif # !STAGING_EXCLUDE_BUILD
 endif # STAGING
diff --git a/net/Kconfig b/net/Kconfig
index 55fd82e..9e4fc29 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -186,7 +186,6 @@ config BRIDGE_NETFILTER
 source "net/netfilter/Kconfig"
 source "net/ipv4/netfilter/Kconfig"
 source "net/ipv6/netfilter/Kconfig"
-source "net/decnet/netfilter/Kconfig"
 source "net/bridge/netfilter/Kconfig"
=20
 endif
@@ -201,7 +200,6 @@ source "net/802/Kconfig"
 source "net/bridge/Kconfig"
 source "net/dsa/Kconfig"
 source "net/8021q/Kconfig"
-source "net/decnet/Kconfig"
 source "net/llc/Kconfig"
 source "net/ipx/Kconfig"
 source "drivers/net/appletalk/Kconfig"
diff --git a/net/decnet/Kconfig b/net/decnet/Kconfig
index 7914fd6..9d17166 100644
--- a/net/decnet/Kconfig
+++ b/net/decnet/Kconfig
@@ -41,3 +41,6 @@ config DECNET_ROUTER
=20
 	  See <file:Documentation/networking/decnet.txt> for more information.
=20
+if NETFILTER
+source "net/decnet/netfilter/Kconfig"
+endif
--=20
1.7.2.3
