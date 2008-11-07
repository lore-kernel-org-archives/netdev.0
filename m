From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] mark flow_cache_cpu_prepare() as __init
Date: Fri, 7 Nov 2008 06:40:59 +0300
Message-ID: <20081107034059.GA20845@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:27887 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbYKGDhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 22:37:40 -0500
Received: by nf-out-0910.google.com with SMTP id d3so519559nfc.21
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2008 19:37:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's called from __init code only. And__devinit in generic networking code
is pretty strange :^)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -307,7 +307,7 @@ void flow_cache_flush(void)
 	put_online_cpus();
 }
 
-static void __devinit flow_cache_cpu_prepare(int cpu)
+static void __init flow_cache_cpu_prepare(int cpu)
 {
 	struct tasklet_struct *tasklet;
 	unsigned long order;
