From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH] dst: check if dst is freed in dst_check()
Date: Tue, 20 Jul 2010 11:49:20 +0200
Message-ID: <4C457120.9070105@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030004040008030506080408"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60471 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758345Ab0GTJt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 05:49:26 -0400
Received: by wwj40 with SMTP id 40so592731wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 02:49:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030004040008030506080408
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

I probably missed something, but I cannot find where obsolete field is checked 
when dst_check() is called. If dst->obsolete is > 1, dst cannot be used!

Attached is a proposal to fix this issue.


Regards,

-- 
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 10
Fax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
Join the Multicore Packet Processing Forum: www.multicorepacketprocessing.com

Ce courriel ainsi que toutes les pièces jointes, est uniquement destiné à son ou 
ses destinataires. Il contient des informations confidentielles qui sont la 
propriété de 6WIND. Toute révélation, distribution ou copie des informations 
qu'il contient est strictement interdite. Si vous avez reçu ce message par 
erreur, veuillez immédiatement le signaler à l'émetteur et détruire toutes les 
données reçues.

This e-mail message, including any attachments, is for the sole use of the 
intended recipient(s) and contains information that is confidential and 
proprietary to 6WIND. All unauthorized review, use, disclosure or distribution 
is prohibited. If you are not the intended recipient, please contact the sender 
by reply e-mail and destroy all copies of the original message.

--------------030004040008030506080408
Content-Type: text/x-diff;
 name="0001-dst-check-if-dst-is-freed-in-dst_check.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-dst-check-if-dst-is-freed-in-dst_check.patch"

>From 69990a516f4b5b48608b0ea283dfac6f1fa110b3 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Jul 2010 11:35:53 +0200
Subject: [PATCH] dst: check if dst is freed in dst_check()

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/dst.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 81d1413..7bf4f9a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -319,6 +319,8 @@ static inline int dst_input(struct sk_buff *skb)
 
 static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 {
+	if (dst->obsolete > 1)
+		return NULL;
 	if (dst->obsolete)
 		dst = dst->ops->check(dst, cookie);
 	return dst;
-- 
1.5.4.5


--------------030004040008030506080408--
