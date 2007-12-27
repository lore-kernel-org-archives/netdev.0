From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange Panic (Deadlock)
Date: Thu, 27 Dec 2007 08:19:54 +0100
Message-ID: <20071227071954.GA1670@ff.dom.local>
References: <20071226185822.GC3061@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:21112 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbXL0HOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 02:14:18 -0500
Received: by fk-out-0910.google.com with SMTP id z23so3166229fkz.5
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2007 23:14:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071226185822.GC3061@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-12-2007 19:58, Jarek Poplawski wrote:
> ...

And here is one more: this place needs more advanced debugging, but
let's check something simple at the beginning... (and just like before
- could be tested with or without these earlier patches).

Jarek P.
 
[PATCH 4/3] (for testing only)
---

diff -Nurp linux-2.6.23-/kernel/timer.c linux-2.6.23+/kernel/timer.c
--- linux-2.6.23-/kernel/timer.c	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23+/kernel/timer.c	2007-12-27 08:07:20.000000000 +0100
@@ -603,7 +603,10 @@ static int cascade(tvec_base_t *base, tv
 	 * don't have to detach them individually.
 	 */
 	list_for_each_entry_safe(timer, tmp, &tv_list, entry) {
-		BUG_ON(tbase_get_base(timer->base) != base);
+		if (tbase_get_base(timer->base) != base) {
+			print_ip_sym((long)timer->function);
+			BUG_ON(1);
+		}
 		internal_add_timer(base, timer);
 	}
 
