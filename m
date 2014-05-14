From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 04/11] net: dsa: retain a per-port device_node pointer
Date: Tue, 13 May 2014 22:00:30 -0700
Message-ID: <1400043637-9799-5-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:59953 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaENFBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:20 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so820896pbc.28
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:20 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will later use the per-port device_node pointer to fetch a bunch of
port-specific properties.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9a16c5290738..c435eaa772d5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -41,6 +41,7 @@ struct dsa_chip_data {
 	 * or any other string to indicate this is a physical port.
 	 */
 	char		*port_names[DSA_MAX_PORTS];
+	struct device_node *port_dn[DSA_MAX_PORTS];
 
 	/*
 	 * An array (with nr_chips elements) of which element [a]
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7808dbceff96..ac05d55dfdd3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -432,6 +432,8 @@ static int dsa_of_probe(struct platform_device *pdev)
 			if (!port_name)
 				continue;
 
+			cd->port_dn[port_index] = port;
+
 			cd->port_names[port_index] = kstrdup(port_name,
 					GFP_KERNEL);
 			if (!cd->port_names[port_index]) {
-- 
1.9.1
