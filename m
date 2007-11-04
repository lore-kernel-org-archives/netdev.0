From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Sun, 04 Nov 2007 18:58:13 -0500
Message-ID: <1194220693.4438.75.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WcY3ie+cTHpvsZzuEMyy"
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:32504 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbXKDX6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 18:58:23 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1770824wah
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2007 15:58:23 -0800 (PST)
In-Reply-To: <472D1DC2.9000106@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WcY3ie+cTHpvsZzuEMyy
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2007-04-11 at 02:17 +0100, Jarek Poplawski wrote:

> So, even if not full ntohl(), some byte moving seems to be
> necessary here.

I thinking you were close. I am afraid my brain is congested, even the
esspresso didnt help my thinking. 
It could be done with just fshift on the slow path (config time) of one
was to think hard;-> I am not too happy with the extra conversion on the
fast path, but how about the untested attached patch?

cheers,
jamal
 

--=-WcY3ie+cTHpvsZzuEMyy
Content-Disposition: attachment; filename=p0-u32
Content-Type: text/x-patch; name=p0-u32; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9e98c6e..6dd569b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -93,7 +93,7 @@ static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fsh
 {
 	unsigned h = (key & sel->hmask)>>fshift;
 
-	return h;
+	return ntohl(h);
 }
 
 static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_result *res)
@@ -615,7 +615,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	n->handle = handle;
 {
 	u8 i = 0;
-	u32 mask = s->hmask;
+	u32 mask = ntohl(s->hmask);
 	if (mask) {
 		while (!(mask & 1)) {
 			i++;

--=-WcY3ie+cTHpvsZzuEMyy--

