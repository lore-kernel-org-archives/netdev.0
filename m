From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Remove unnecessary semicolons after switch
 statements
Date: Fri, 14 May 2010 13:58:26 -0700
Message-ID: <1273870706.1705.8.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2243 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759925Ab0ENU61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 16:58:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also added an explicit break; to avoid
a fallthrough in net/ipv4/tcp_input.c

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlan_core.c |    2 +-
 net/core/ethtool.c    |    4 ++--
 net/ipv4/tcp.c        |    2 +-
 net/ipv4/tcp_input.c  |    5 +++--
 net/rds/tcp_connect.c |    2 +-
 net/socket.c          |    2 +-
 net/xfrm/xfrm_hash.h  |    6 +++---
 7 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c584a0a..bd537fc 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -61,7 +61,7 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 					dev->dev_addr))
 			skb->pkt_type = PACKET_HOST;
 		break;
-	};
+	}
 	return 0;
 }
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1a7db92..a0f4964 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -522,7 +522,7 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			goto unknown_filter;
-		};
+		}
 
 		/* now the rest of the filters */
 		switch (fsc->fs.flow_type) {
@@ -646,7 +646,7 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			break;
-		};
+		}
 		sprintf(p, "\tVLAN: %d, mask: 0x%x\n",
 			fsc->fs.vlan_tag, fsc->fs.vlan_tag_mask);
 		p += ETH_GSTRING_LEN;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8ce2974..9d4c8fc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2215,7 +2215,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	default:
 		/* fallthru */
 		break;
-	};
+	}
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e82162c..3e6dafc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3845,12 +3845,13 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 					/* 16-bit multiple */
 					opt_rx->cookie_plus = opsize;
 					*hvpp = ptr;
+					break;
 				default:
 					/* ignore option */
 					break;
-				};
+				}
 				break;
-			};
+			}
 
 			ptr += opsize-2;
 			length -= opsize;
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 0562562..c397524 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -141,7 +141,7 @@ void rds_tcp_conn_shutdown(struct rds_connection *conn)
 
 		release_sock(sock->sk);
 		sock_release(sock);
-	};
+	}
 
 	if (tc->t_tinc) {
 		rds_inc_put(&tc->t_tinc->ti_inc);
diff --git a/net/socket.c b/net/socket.c
index dae8c6b..f9f7d08 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2615,7 +2615,7 @@ static int bond_ioctl(struct net *net, unsigned int cmd,
 		return dev_ioctl(net, cmd, uifr);
 	default:
 		return -EINVAL;
-	};
+	}
 }
 
 static int siocdevprivate_ioctl(struct net *net, unsigned int cmd,
diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 1396572..8e69533 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -55,7 +55,7 @@ static inline unsigned __xfrm_src_hash(xfrm_address_t *daddr,
 	case AF_INET6:
 		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
 		break;
-	};
+	}
 	return (h ^ (h >> 16)) & hmask;
 }
 
@@ -102,7 +102,7 @@ static inline unsigned int __sel_hash(struct xfrm_selector *sel, unsigned short
 
 		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
 		break;
-	};
+	}
 	h ^= (h >> 16);
 	return h & hmask;
 }
@@ -119,7 +119,7 @@ static inline unsigned int __addr_hash(xfrm_address_t *daddr, xfrm_address_t *sa
 	case AF_INET6:
 		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
 		break;
-	};
+	}
 	h ^= (h >> 16);
 	return h & hmask;
 }


