From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH] build: unbreak linkage of m_xt.so
Date: Sun, 16 Dec 2012 01:32:48 +0100
Message-ID: <1355617968-26138-1-git-send-email-jengelh@inai.de>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr>
Cc: vapier@gentoo.org, netdev@vger.kernel.org, jhs@mojatatu.com,
	urykhy@gmail.com, shemonc@gmail.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit v3.7.0~10 caused the variable new PKG_CONFIG variable never
to be present at the time of calling make, leading to tc/m_xt.so
not linked with -lxtables (result from pkg-config xtables --libs),
that in turn leading to

tc: symbol lookup error: /usr/lib64/tc//m_xt.so: undefined symbol:
xtables_init_all

Fixing that.

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---
 configure |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure b/configure
index 9912114..573ee55 100755
--- a/configure
+++ b/configure
@@ -4,7 +4,6 @@
 INCLUDE=${1:-"$PWD/include"}
 : ${PKG_CONFIG:=pkg-config}
 : ${CC=gcc}
-echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
 
 # Make a temp directory in build tree.
 TMPDIR=$(mktemp -d config.XXXXXX)
@@ -224,6 +223,7 @@ rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
 }
 
 echo "# Generated config based on" $INCLUDE >Config
+echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
 
 echo "TC schedulers"
 
-- 
1.7.10.4

