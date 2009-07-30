From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] [IPV4]: Buffer overflow
Date: Thu, 30 Jul 2009 11:46:59 +0200
Message-ID: <4A716C13.6030208@gmail.com>
References: <4A702A02.30509@gmail.com> <4A70C6FF.9060302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:51368 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbZG3JoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 05:44:04 -0400
Received: by ewy10 with SMTP id 10so599684ewy.37
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 02:44:03 -0700 (PDT)
In-Reply-To: <4A70C6FF.9060302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If arp_format_neigh_entry() can be called with n->dev->addr_len == 0, then a
write to hbuffer[-1] occurs.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Op 30-07-09 00:02, Jarek Poplawski schreef:
> Roel Kluin wrote, On 07/29/2009 12:52 PM:

>> -	hbuffer[--k] = 0;
>> +	if (k != 0)
>> +		hbuffer[--k] = 0;
> 
> 
> I guess for k == 0 we need hbuffer[0] = 0 too.
> 
> Jarek P.

Thanks, updated patch below.

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c29d75d..090e999 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1304,7 +1304,9 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 		hbuffer[k++] = hex_asc_lo(n->ha[j]);
 		hbuffer[k++] = ':';
 	}
-	hbuffer[--k] = 0;
+	if (k != 0)
+		--k;
+	hbuffer[k] = 0;
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	}
 #endif
