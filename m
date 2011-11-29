From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: Fix build problems when IPv6 is not enabled
Date: Tue, 29 Nov 2011 15:08:18 -0500
Message-ID: <20111129200818.19875.72359.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent fix to the the NetLabel code caused build problem with
configurations that did not have IPv6 enabled; see below:

 netlabel_kapi.c: In function 'netlbl_cfg_unlbl_map_add':
 netlabel_kapi.c:165:4:
  error: implicit declaration of function 'netlbl_af6list_add'

This patch fixes this problem by making the IPv6 specific code conditional
on the IPv6 configuration flags as we done in the rest of NetLabel and the
network stack as a whole.  We have to move some variable declarations
around as a result so things may not be quite as pretty, but at least it
builds cleanly now.

Some additional IPv6 conditionals were added to the NetLabel code as well
for the sake of consistency.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/netlabel/netlabel_kapi.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 3735297..e4bbe94 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -148,6 +148,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			if (ret_val != 0)
 				goto cfg_unlbl_map_add_failure;
 			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		case AF_INET6:
 			addr6 = addr;
 			mask6 = mask;
@@ -167,6 +168,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			if (ret_val != 0)
 				goto cfg_unlbl_map_add_failure;
 			break;
+#endif /* IPv6 */
 		default:
 			goto cfg_unlbl_map_add_failure;
 			break;
@@ -225,9 +227,11 @@ int netlbl_cfg_unlbl_static_add(struct net *net,
 	case AF_INET:
 		addr_len = sizeof(struct in_addr);
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		addr_len = sizeof(struct in6_addr);
 		break;
+#endif /* IPv6 */
 	default:
 		return -EPFNOSUPPORT;
 	}
@@ -266,9 +270,11 @@ int netlbl_cfg_unlbl_static_del(struct net *net,
 	case AF_INET:
 		addr_len = sizeof(struct in_addr);
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		addr_len = sizeof(struct in6_addr);
 		break;
+#endif /* IPv6 */
 	default:
 		return -EPFNOSUPPORT;
 	}
