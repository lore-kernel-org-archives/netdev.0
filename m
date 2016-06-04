From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/9] net: dsa: Prepare to support legacy DT binding
Date: Fri,  3 Jun 2016 17:05:21 -0700
Message-ID: <1464998733-10405-2-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33558 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbcFDAFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:42 -0400
Received: by mail-pa0-f66.google.com with SMTP id di3so6951109pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:42 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting the legacy DT binding, call
dsa_get_ports() early on to allow two different parsing code paths to be
called.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4e5051bed643..b5640d8ffbae 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -552,7 +552,7 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 	return ports;
 }
 
-static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+static int __dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 {
 	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
@@ -622,6 +622,16 @@ out:
 	return err;
 }
 
+static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+{
+	struct device_node *ports = dsa_get_ports(ds, np);
+
+	if (IS_ERR(ports))
+		return PTR_ERR(ports);
+
+	return __dsa_register_switch(ds, np);
+}
+
 int dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 {
 	int err;
-- 
2.7.4
