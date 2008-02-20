From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 20 Feb 2008 18:04:09 -0500
Message-ID: <47BCB1E9.8020102@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com> <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com> <20080220013824.GA5416@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:3719 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbYBTXEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:04:06 -0500
In-Reply-To: <20080220013824.GA5416@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch fixes the problem for me.  Do we want to accept this
patch and call it a day or continue investigating the source of the problem?

Patch applies to 2.6.24.2, but doesn't apply to 2.6.25-rc.  If everyone
agrees that this is the right solution, I will resubmit with a proper
subject line and description.

Tony

--- linux-2.6.24.2/include/net/sock.h.orig	2008-02-20 17:19:20.000000000 -0500
+++ linux-2.6.24.2/include/net/sock.h	2008-02-20 17:25:55.000000000 -0500
@@ -1236,8 +1236,10 @@ static inline struct sk_buff *sk_stream_
 {
 	struct sk_buff *skb;
 
-	/* The TCP header must be at least 32-bit aligned.  */
-	size = ALIGN(size, 4);
+	/* The TCP header must be at least 32-bit aligned, but some chipsets
+	 * such as Broadcom BCM5701 require at least 16-byte alignment.
+	 */
+	size = ALIGN(size, 16);
 
 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (skb) {


