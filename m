From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [XFRM]: alg_key_len should be unsigned to avoid integer divides
Date: Sat, 12 Jan 2008 18:29:32 +0100
Message-ID: <4788F8FC.3010001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010505080507040305090608"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37125 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317AbYALR3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 12:29:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010505080507040305090608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

alg_key_len is currently defined as 'signed int'. This unfortunatly leads
to integer divides in several paths.

Converting it to unsigned is safe and saves 208 bytes of text on i386.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010505080507040305090608
Content-Type: text/plain;
 name="xfrm_alg_key_len.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm_alg_key_len.patch"

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 1131eab..f8507ee 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -92,7 +92,7 @@ struct xfrm_replay_state
 
 struct xfrm_algo {
 	char	alg_name[64];
-	int	alg_key_len;    /* in bits */
+	unsigned int	alg_key_len;    /* in bits */
 	char	alg_key[0];
 };
 

--------------010505080507040305090608--
