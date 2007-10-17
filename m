From: Charles Hardin <chardin@2wire.com>
Subject: [PATCH] pfkey: sending an SADB_GET responds with an SADB_GET
Date: Wed, 17 Oct 2007 14:36:10 -0700
Message-ID: <C33BCE5A.25D04%chardin@2wire.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ims.2wire.com ([206.171.6.87]:27618 "EHLO ims.2wire.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761710AbXJQVw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 17:52:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel needs to respond to an SADB_GET with the same message type to conform
to the RFC 2367 Section 3.1.5

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7969f8a..fb4fee1 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1552,7 +1552,7 @@ static int pfkey_get(struct sock *sk, struct sk_buff
*skb,
 
        out_hdr = (struct sadb_msg *) out_skb->data;
        out_hdr->sadb_msg_version = hdr->sadb_msg_version;
-       out_hdr->sadb_msg_type = SADB_DUMP;
+       out_hdr->sadb_msg_type = SADB_GET;
        out_hdr->sadb_msg_satype = pfkey_proto2satype(proto);
        out_hdr->sadb_msg_errno = 0;
        out_hdr->sadb_msg_reserved = 0;

