From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH]
Date: Thu, 26 Sep 2013 08:27:07 -0700
Message-ID: <1380209227.3165.176.camel@edumazet-glaptop>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>
	 <1380204582-27144-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:60566 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab3IZP1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 11:27:22 -0400
Received: by mail-pa0-f44.google.com with SMTP id lf10so1456400pab.31
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 08:27:22 -0700 (PDT)
In-Reply-To: <1380204582-27144-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 16:09 +0200, Nikolay Aleksandrov wrote:
> Factor out the code that extracts the ports from skb_flow_dissect and
> add a new function skb_flow_get_ports which can be re-used.
> 
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> v2: new patch
> v3: fix a bug in skb_flow_dissect where thoff didn't have poff added by
>     modifying thoff directly in skb_flow_get_ports as it's done anyway.
>     Also add the necessary export symbol for skb_flow_get_ports.
> This seems like a good idea because there're other users that can re-use
> it later as well.

Wait a minute.... existing code seems buggy.

Daniel, any objection if I submit this fix ?

(commit 8ed781668dd49b608f)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1929af8..8d7d0dd 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -154,8 +154,8 @@ ipv6:
 	if (poff >= 0) {
 		__be32 *ports, _ports;
 
-		nhoff += poff;
-		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
+		ports = skb_header_pointer(skb, nhoff + poff,
+					   sizeof(_ports), &_ports);
 		if (ports)
 			flow->ports = *ports;
 	}
