From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 08:25:38 -0400
Message-ID: <1275481538.14363.10.camel@bigi>
References: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
	 <1275395667.3587.38.camel@bigi>
	 <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	 <1275481219.14363.6.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47485 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757697Ab0FBMZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:25:53 -0400
Received: by vws11 with SMTP id 11so2509378vws.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 05:25:53 -0700 (PDT)
In-Reply-To: <1275481219.14363.6.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 08:21 -0400, jamal wrote:

> Can we make the fix very simple please? i.e no copy bits, this is the
> fast path.

Example, something along lines of:

---
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9627542..dde7a23 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -135,6 +135,9 @@ next_knode:
 
 for (i = n->sel.nkeys; i>0; i--, key++) {
 
+        int toff = key->off+(off2&key->offmask)- 4;
+        if (unlikely(toff > skb->len))
+              /* bailout here - needs some thought */
         if ((*(__be32*)(ptr+key->off+(off2&key->offmask))^key->v
             n = n->next;
             goto next_knode;
----


cheers,
jamal

