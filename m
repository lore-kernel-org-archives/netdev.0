From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] netfilter: undefined reference to 'nf_conntrack_tstamp_*'
Date: Thu, 20 Jan 2011 11:16:12 -0800
Message-ID: <20110120191612.24205.73463.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, pablo@netfilter.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/built-in.o: In function `nf_conntrack_init_net':
net/netfilter/nf_conntrack_core.c:1521:
	undefined reference to `nf_conntrack_tstamp_init'
net/netfilter/nf_conntrack_core.c:1531:
	undefined reference to `nf_conntrack_tstamp_fini'

Add 'selects' notation to Kconfig to include NF_CONNTRACK_TIMESTAMP
this resolves all the config files I tested.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
---

 net/netfilter/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index faf7412..2079911 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -27,6 +27,7 @@ config NETFILTER_NETLINK_LOG
 config NF_CONNTRACK
 	tristate "Netfilter connection tracking support"
 	default m if NETFILTER_ADVANCED=n
+	select NF_CONNTRACK_TIMESTAMP
 	help
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
@@ -87,7 +88,7 @@ config NF_CONNTRACK_EVENTS
 
 config NF_CONNTRACK_TIMESTAMP
 	bool  'Connection tracking timestamping'
-	depends on NETFILTER_ADVANCED
+	default m if NETFILTER_ADVANCED
 	help
 	  This option enables support for connection tracking timestamping.
 	  This allows you to store the flow start-time and to obtain

