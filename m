From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 11/12] net: rocker: have flow api calls set
 cookie value
Date: Tue, 20 Jan 2015 12:31:06 -0800
Message-ID: <20150120203104.1741.25426.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33996 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbbATUb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:31:26 -0500
Received: by mail-oi0-f43.google.com with SMTP id z81so5835591oif.2
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:31:25 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 5ba46f6..3ceb313 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3891,7 +3891,7 @@ static int rocker_flow_set_ig_port(struct net_device *dev,
 	in_lport_mask = rule->matches[0].mask_u32;
 	goto_tbl = rocker_goto_value(rule->actions[0].args[0].value_u16);
 
-	return rocker_flow_tbl_ig_port(rocker_port, flags, 0,
+	return rocker_flow_tbl_ig_port(rocker_port, flags, rule->uid,
 				       in_lport, in_lport_mask,
 				       goto_tbl);
 }
@@ -3948,7 +3948,7 @@ static int rocker_flow_set_vlan(struct net_device *dev,
 		}
 	}
 
-	return rocker_flow_tbl_vlan(rocker_port, flags, 0, in_lport,
+	return rocker_flow_tbl_vlan(rocker_port, flags, rule->uid, in_lport,
 				    vlan_id, vlan_id_mask, goto_tbl,
 				    untagged, new_vlan_id);
 }
@@ -4022,7 +4022,7 @@ static int rocker_flow_set_term_mac(struct net_device *dev,
 		}
 	}
 
-	return rocker_flow_tbl_term_mac(rocker_port, 0,
+	return rocker_flow_tbl_term_mac(rocker_port, rule->uid,
 					in_lport, in_lport_mask,
 					ethtype, eth_dst, eth_dst_mask,
 					vlan_id, vlan_id_mask,
@@ -4117,7 +4117,7 @@ static int rocker_flow_set_bridge(struct net_device *dev,
 	}
 
 	/* Ignoring eth_dst_mask it seems to cause a EINVAL return code */
-	return rocker_flow_tbl_bridge(rocker_port, flags, 0,
+	return rocker_flow_tbl_bridge(rocker_port, flags, rule->uid,
 				      eth_dst, eth_dst_mask,
 				      vlan_id, tunnel_id,
 				      goto_tbl, group_id, copy_to_cpu);
@@ -4219,7 +4219,7 @@ static int rocker_flow_set_acl(struct net_device *dev,
 		}
 	}
 
-	return rocker_flow_tbl_acl(rocker_port, flags, 0,
+	return rocker_flow_tbl_acl(rocker_port, flags, rule->uid,
 				   in_lport, in_lport_mask,
 				   eth_src, eth_src_mask,
 				   eth_dst, eth_dst_mask, ethtype,
@@ -4279,6 +4279,8 @@ static int rocker_flow_set_group_slice_l3_unicast(struct net_device *dev,
 		}
 	}
 
+	entry->cookie = rule->uid;
+
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
 
@@ -4330,6 +4332,8 @@ static int rocker_flow_set_group_slice_l2_rewrite(struct net_device *dev,
 		}
 	}
 
+	entry->cookie = rule->uid;
+
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
 
@@ -4381,6 +4385,8 @@ static int rocker_flow_set_group_slice_l2(struct net_device *dev,
 		}
 	}
 
+	entry->cookie = rule->uid;
+
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
 
