From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_try_coalesce bug?
Date: Tue, 22 Apr 2014 14:37:33 -0700
Message-ID: <1398202653.29946.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>
	 <1398172293.29946.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5356C518.7050602@ericsson.com>
	 <1398197116.29946.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5356D2AF.7030401@ericsson.com>
	 <1398202178.29946.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:37525 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbaDVVhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 17:37:37 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so52016pde.1
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 14:37:36 -0700 (PDT)
In-Reply-To: <1398202178.29946.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 14:29 -0700, Eric Dumazet wrote:

> Then if you do that, you also need to change head->data_len !

Untested patch would be :

diff --git a/net/tipc/link.c b/net/tipc/link.c
index c5190ab75290..85077dd7c63e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2349,6 +2349,7 @@ int tipc_link_frag_rcv(struct sk_buff **head, struct sk_buff **tail,
 			(*tail)->next = frag;
 		*tail = frag;
 		(*head)->truesize += frag->truesize;
+		(*head)->data_len += frag->len;
 	}
 	if (fragid == LAST_FRAGMENT) {
 		*fbuf = *head;
