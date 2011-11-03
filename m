From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: validate NLA_MSECS length
Date: Thu, 03 Nov 2011 11:07:32 +0100
Message-ID: <1320314852.3950.36.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:45506 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740Ab1KCKHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:07:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

L2TP for example uses NLA_MSECS like this:
policy:
        [L2TP_ATTR_RECV_TIMEOUT]        = { .type = NLA_MSECS, },
code:
        if (info->attrs[L2TP_ATTR_RECV_TIMEOUT])
                cfg.reorder_timeout = nla_get_msecs(info->attrs[L2TP_ATTR_RECV_TIMEOUT]);

As nla_get_msecs() is essentially nla_get_u64() plus the
conversion to a HZ-based value, this will not properly
reject attributes from userspace that aren't long enough
and might overrun the message.

Add NLA_MSECS to the attribute minlen array to check the
size properly.

Cc: Thomas Graf <tgraf@suug.ch>
Cc: stable@vger.kernel.org
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 lib/nlattr.c |    1 +
 1 file changed, 1 insertion(+)

--- a/lib/nlattr.c	2011-04-29 11:34:55.000000000 +0200
+++ b/lib/nlattr.c	2011-11-03 11:02:10.000000000 +0100
@@ -20,6 +20,7 @@ static const u16 nla_attr_minlen[NLA_TYP
 	[NLA_U16]	= sizeof(u16),
 	[NLA_U32]	= sizeof(u32),
 	[NLA_U64]	= sizeof(u64),
+	[NLA_MSECS]	= sizeof(u64),
 	[NLA_NESTED]	= NLA_HDRLEN,
 };
 
