From: "Leonid Slobodchikov" <curvex@gmail.com>
Subject: [PATCH] at91_ether: multicast packet are not received due to incorrect setting of the multicast hashtable, kernel linux-2.6.17.3
Date: Sun, 26 Oct 2008 23:31:17 +0600
Message-ID: <5f59dc1a0810261031w2fa3f40bne1edb2d710f64404@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_61363_10860904.1225042277935"
Cc: linux-arm-kernel@lists.arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:43288 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbYJZRbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 13:31:19 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1416525muf.1
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2008 10:31:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_61363_10860904.1225042277935
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

Multicast packets are not received by the Ethernet driver for the
Atmel AT91RM9200. This is due to incorrect mc_filter array index
evaluation in the at91ether_sethashtable function. The point is that
AT91_EMAC_HSH and AT91_EMAC_HSL registers are 64-bit length. So when
evaluating the index the bit number must be diveded at 64, which is
2^6, not 2^5.
The below is a fix for that issue.


--- drivers/net/arm/at91_ether.c.orig	2006-06-30 20:37:38.000000000 +0300
+++ drivers/net/arm/at91_ether.c	2008-10-26 17:35:50.000000000 +0200
@@ -520,7 +520,7 @@ static void at91ether_sethashtable(struc
 		if (!curr) break;	/* unexpected end of list */

 		bitnr = hash_get_index(curr->dmi_addr);
-		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
+		mc_filter[bitnr >> 6] |= 1 << (bitnr & 31);
 	}

 	at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);

Signed-off-by: Leonid V. Slobodchikov <curvex@gmail.com>

Best regards,
Leonid Slobodchikov

------=_Part_61363_10860904.1225042277935
Content-Type: application/x-gzip; name=at91_ether.patch.gz
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fmrydibe0
Content-Disposition: attachment; filename=at91_ether.patch.gz

H4sICJGoBEkAA2F0OTFfZXRoZXIucGF0Y2gAfZBfS8MwFMWf209xfZFuXdp0ZX/strIhwh70aeKL
jJImt1tY20iazQn63U1XRAQ1BC735JwfN5cQAkLLE+omrNGETFchMzdRhmaPOuCB0nLnDCkdE3tj
CkOaxJMkngb064BPY0pd3/f/JbWQKYkoGY4hsoRRMqI/IPbdXS6BjIZ0MAG/K1ZoDDOSw0lJAS3w
wssaW1izNywv0WuMPnIXHEcW4F3xo9Y9yDWyw8wJ+3Cs8fyC3KAArAWoAkrZGOiHLrSZXJpawwJa
XLZDk8la4NlrKSQVlcyYELo3c4njVDwrZGlQP3ehNIXRFt4XEMF8Dl4nXkMcWbv/q338lx2cj8s4
3coqxrNXLQ16q0fb3z2sbrP1Zj2AbyTd2pS7kbsaBVFFQfK3BO5R1XZNTwFsSpUrwffyoE4wt585
4Xm5q5gsA66q1P0EYts5ZvkBAAA=
------=_Part_61363_10860904.1225042277935--
