From: "Anthony G. Basile" <basile@opensource.dyc.edu>
Subject: [PATCH] netfilter: install nf_nat.h and related headers to INSTALL_HDR_PATH
Date: Sat,  3 Sep 2011 14:49:44 -0400
Message-ID: <1315075784-10163-1-git-send-email-basile@opensource.dyc.edu>
Cc: kaber@trash.net, basile@opensource.dyc.edu, blueness@gentoo.org,
	gurligebis@gentoo.org, base-system@gentoo.org, kernel@gentoo.org,
	toolchain@gentoo.org, mchehab@redhat.com, hverkuil@xs4all.nl,
	laurent.pinchart@ideasonboard.com, arnd@arndb.de,
	eparis@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently nf_nat.h, nf_conntrack_tuple.h and related headers under
include/net/netfilter are not installed as part of the public kernel
headers.   However, there are userland applications, other than iptables
which ships with its own headers, which need these to make use of NAT in
the kernel's netfilter API.  For example, miniupnpd, requires them and is
forced to search /usr/src/linux when building.

This patch makes these headers public by installing them in
INSTALL_HDR_PATH.

See: https://bugs.gentoo.org/376873

Signed-off-by: Anthony G. Basile <blueness@gentoo.org>
---
 include/Kbuild                    |    1 +
 include/linux/Kbuild              |    1 +
 include/net/Kbuild                |    1 +
 include/net/netfilter/Kbuild      |    6 ++++++
 include/net/netfilter/ipv4/Kbuild |    1 +
 include/net/netfilter/ipv6/Kbuild |    2 ++
 6 files changed, 12 insertions(+), 0 deletions(-)
 create mode 100644 include/net/Kbuild
 create mode 100644 include/net/netfilter/Kbuild
 create mode 100644 include/net/netfilter/ipv4/Kbuild
 create mode 100644 include/net/netfilter/ipv6/Kbuild

diff --git a/include/Kbuild b/include/Kbuild
index 8d226bf..9fb8300 100644
--- a/include/Kbuild
+++ b/include/Kbuild
@@ -5,6 +5,7 @@ header-y += asm-generic/
 header-y += linux/
 header-y += sound/
 header-y += mtd/
+header-y += net/
 header-y += rdma/
 header-y += video/
 header-y += drm/
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 619b565..5569432 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -228,6 +228,7 @@ header-y += keyboard.h
 header-y += keyctl.h
 header-y += l2tp.h
 header-y += limits.h
+header-y += list_nulls.h
 header-y += llc.h
 header-y += loop.h
 header-y += lp.h
diff --git a/include/net/Kbuild b/include/net/Kbuild
new file mode 100644
index 0000000..9546082
--- /dev/null
+++ b/include/net/Kbuild
@@ -0,0 +1 @@
+header-y += netfilter/
diff --git a/include/net/netfilter/Kbuild b/include/net/netfilter/Kbuild
new file mode 100644
index 0000000..143f188
--- /dev/null
+++ b/include/net/netfilter/Kbuild
@@ -0,0 +1,6 @@
+header-y += nf_nat.h
+header-y += nf_conntrack.h
+header-y += nf_conntrack_tuple.h
+header-y += nf_conntrack_extend.h
+header-y += ipv4/
+header-y += ipv6/
diff --git a/include/net/netfilter/ipv4/Kbuild b/include/net/netfilter/ipv4/Kbuild
new file mode 100644
index 0000000..a15e304
--- /dev/null
+++ b/include/net/netfilter/ipv4/Kbuild
@@ -0,0 +1 @@
+header-y += nf_conntrack_ipv4.h
diff --git a/include/net/netfilter/ipv6/Kbuild b/include/net/netfilter/ipv6/Kbuild
new file mode 100644
index 0000000..07d43a4
--- /dev/null
+++ b/include/net/netfilter/ipv6/Kbuild
@@ -0,0 +1,2 @@
+header-y += nf_conntrack_icmpv6.h
+header-y += nf_conntrack_ipv6.h
-- 
1.7.0.4

