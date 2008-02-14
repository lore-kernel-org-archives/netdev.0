From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][KEY] fix bug in spdadd
Date: Thu, 14 Feb 2008 20:55:40 +0900
Message-ID: <47B42C3C.5090104@miyazawa.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_catalunya.miyazawa.org-24026-1202989923-0001-2"
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:56156 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758551AbYBNMA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 07:00:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_catalunya.miyazawa.org-24026-1202989923-0001-2
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit

This patch fix a BUG when adding spds which have
same selector.

Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>

--
Kazunori Miyazawa



--=_catalunya.miyazawa.org-24026-1202989923-0001-2
Content-Type: text/x-patch; name="af_key.diff"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_key.diff"

diff --git a/net/key/af_key.c b/net/key/af_key.c
index b3ac85e..1c85392 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2291,6 +2291,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	return 0;
 
 out:
+	xp->dead = 1;
 	xfrm_policy_destroy(xp);
 	return err;
 }

--=_catalunya.miyazawa.org-24026-1202989923-0001-2--
