From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu,  4 Dec 2014 09:57:13 +0100
Message-ID: <1417683438-10935-2-git-send-email-jiri@resnulli.us>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:52557 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaLDI5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:57:23 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so13739095wgh.22
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 00:57:22 -0800 (PST)
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h | 1 +
 ip/ipaddress.c          | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 4732063..a6e2594 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -145,6 +145,7 @@ enum {
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
 	IFLA_CARRIER_CHANGES,
+	IFLA_PHYS_SWITCH_ID,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4d99324..bd36a07 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -589,6 +589,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				      b1, sizeof(b1)));
 	}
 
+	if (tb[IFLA_PHYS_SWITCH_ID]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "switchid %s ",
+			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
+				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
+				      b1, sizeof(b1)));
+	}
+
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-- 
1.9.3
