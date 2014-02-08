From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: fix 'ip rule' iif/oif device rename
Date: Fri,  7 Feb 2014 16:23:48 -0800
Message-ID: <1391819028-10722-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Chris Davis <chrismd@google.com>,
	Carlo Contavalli <ccontavalli@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46783 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaBHAYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 19:24:09 -0500
Received: by mail-pb0-f52.google.com with SMTP id jt11so3924006pbb.25
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 16:24:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

ip rules with iif/oif references do not update:
(detach/attach) across interface renames.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
CC: Willem de Bruijn <willemb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Chris Davis <chrismd@google.com>
CC: Carlo Contavalli <ccontavalli@google.com>

Google-Bug-Id: 12936021
---
 net/core/fib_rules.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index f409e0bd35c0..185c341fafbd 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -745,6 +745,13 @@ static int fib_rules_event(struct notifier_block *=
this, unsigned long event,
 			attach_rules(&ops->rules_list, dev);
 		break;
=20
+	case NETDEV_CHANGENAME:
+		list_for_each_entry(ops, &net->rules_ops, list) {
+			detach_rules(&ops->rules_list, dev);
+			attach_rules(&ops->rules_list, dev);
+		}
+		break;
+
 	case NETDEV_UNREGISTER:
 		list_for_each_entry(ops, &net->rules_ops, list)
 			detach_rules(&ops->rules_list, dev);
--=20
1.8.3
