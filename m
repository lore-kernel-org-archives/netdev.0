From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Wed, 02 Jan 2008 11:01:33 -0500
Message-ID: <20080102160133.11792.21836.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:54154
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754754AbYABQEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 11:04:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sk_buffs are cloned the iif field of the new, cloned packet is neither
zeroed out or copied from the existing sk_buff.  The result is that the newly
cloned sk_buff has garbage in the iif field which is a Bad Thing.  This patch
fixes this problem by copying the iif field along with the other sk_buff
critical fields in __copy_skb_header().

This patch is needed by some of the labeled networking changes proposed for
2.6.25, does anyone have any objections?
---

 net/core/skbuff.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b4ce9b..9cb7bb7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -371,6 +371,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 	new->tstamp		= old->tstamp;
 	new->dev		= old->dev;
+	new->iif		= old->iif;
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;

