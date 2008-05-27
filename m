From: "Dmitry Petukhov" <dmgenp@gmail.com>
Subject: [PATCH 2.6.26-rc4] fix double call of kfree_skb in net/llc/llc_sap.c
Date: Tue, 27 May 2008 13:09:53 +0600
Message-ID: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:10477 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbYE0HJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 03:09:58 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1634606tic.23
        for <netdev@vger.kernel.org>; Tue, 27 May 2008 00:09:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in function llc_sap_state_proces there was lack of return statement,
and finalizing kfree_skb might be called after skb was already freed
or queued to the user.

following patch adds the necessary return.

---

--- a/net/llc/llc_sap.c 2008-05-27 12:52:01.000000000 +0600
+++ b/net/llc/llc_sap.c 2008-05-27 12:52:37.000000000 +0600
@@ -223,6 +223,7 @@
                        if (sock_queue_rcv_skb(skb->sk, skb))
                                kfree_skb(skb);
                }
+               return;
        }
        kfree_skb(skb);
 }
