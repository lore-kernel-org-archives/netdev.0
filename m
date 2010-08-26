From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 10:03:08 +0200
Message-ID: <1282809788.2476.59.camel@edumazet-laptop>
References: <bug-16529-10286@https.bugzilla.kernel.org/>
	 <20100825153107.2f547f0e.akpm@linux-foundation.org>
	 <4C759F8C.9050301@goop.org>
	 <1282806640.3469.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	"heil@terminal-consulting.de" <heil@terminal-consulting.de>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33954 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab0HZIDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 04:03:13 -0400
Received: by wyb35 with SMTP id 35so1868686wyb.19
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 01:03:12 -0700 (PDT)
In-Reply-To: <1282806640.3469.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the patch, could you test it please ?

Thanks !

[PATCH] l2tp: test for malicious frames in l2tp_eth_dev_recv()

close https://bugzilla.kernel.org/show_bug.cgi?id=16529

Before calling dev_forward_skb(), we should make sure skb contains at
least an ethernet header, even if length included in upper layer said
so.

Reported-by: Thomas Heil <heil@terminal-consulting.de>
Reported-by: Ian Campbell <Ian.Campbell@eu.citrix.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_core.c |    2 +-
 net/l2tp/l2tp_eth.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 58c6c4c..0687c5c 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -132,7 +132,7 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 		printk("\n");
 	}
 
-	if (data_len < ETH_HLEN)
+	if (skb->len < ETH_HLEN)
 		goto error;
 
 	secpath_reset(skb);


