From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: Re: checksum of lsrr
Date: Mon, 23 Jul 2007 00:31:19 +0900 (JST)
Message-ID: <20070723.003119.74728388.chamas@h4.dion.ne.jp>
References: <20070704.222824.74749937.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm05mta.dion.ne.jp ([219.125.112.11]:1149 "HELO
	nm05omta05b.dion.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758181AbXGVPbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 11:31:25 -0400
In-Reply-To: <20070704.222824.74749937.chamas@h4.dion.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello, 

From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: checksum of lsrr
Date: Wed, 04 Jul 2007 22:28:24 +0900 (JST)

> if we change destination address, we need recompute not only ip
> checksum but also tcp's, don't we? 

I was ashamed of myself for much confused. My simple story is:

	rt1 ---- rt2 ---- mybox

rt1 is far from rt2 and when I changed bandwith between rt1 and rt2,
I want to confirm if it was changed correctly. A idea occured to me
is using lsrr. Then I tried with nc but it was not worked. To accept
packet from rt2 to mybox which src and dst address are mybox, I
changed:

--- net/ipv4/fib_frontend.c.orig	2007-07-23 00:01:17.000000000 +0900
+++ net/ipv4/fib_frontend.c	2007-07-23 00:03:11.000000000 +0900
@@ -206,7 +206,7 @@
 
 	if (fib_lookup(&fl, &res))
 		goto last_resort;
-	if (res.type != RTN_UNICAST)
+	if (res.type != RTN_UNICAST && likely(res.type != RTN_LOCAL))
 		goto e_inval_res;
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);

Would you tell me is this acceptable? I'm afraid of security issue.
thanks,
