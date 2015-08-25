From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 4/5] net: dsa: Flag slave network devices with IFF_L2_ONLY
Date: Tue, 25 Aug 2015 15:50:14 -0700
Message-ID: <1440543015-14693-5-git-send-email-f.fainelli@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36168 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024AbbHYWxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:53:52 -0400
Received: by pacgr6 with SMTP id gr6so4825543pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:53:52 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tagging is not supported by the underlying switch driver,
ds->tag_protocol will be set to DSA_TAG_PROTO_NONE, and we should be
flagging the slave network devices with IFF_L2_ONLY such that IP
configuration is denied and they are just control end-points.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cce97385f743..855c66dddced 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1185,6 +1185,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		break;
 #endif
 	default:
+		slave_dev->flags |= IFF_L2_ONLY;
 		p->xmit	= dsa_slave_notag_xmit;
 		break;
 	}
-- 
2.1.0
