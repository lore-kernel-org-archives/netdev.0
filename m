From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] netlink: fix test alignment in
 nla_align_64bit()
Date: Wed, 20 Apr 2016 02:57:58 -0700
Message-ID: <1461146278.10638.253.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
	 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
	 <1461144802.10638.249.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57174F8E.6050201@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34548 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446AbcDTJ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 05:57:56 -0400
Received: by mail-pf0-f182.google.com with SMTP id y69so1056262pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 02:57:55 -0700 (PDT)
In-Reply-To: <57174F8E.6050201@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 11:44 +0200, Nicolas Dichtel wrote:
> Le 20/04/2016 11:33, Eric Dumazet a =C3=A9crit :
> [snip]
> > How have you tested your patch exactly ?
> As stated in the cover letter, I didn't test it.


You certainly can test this, by tweaking HAVE_EFFICIENT_UNALIGNED_ACCES=
S
and adding another assertion in the code.

By testing it you would have caught a real bug, since David incorrectly
used HAVE_EFFICIENT_UNALIGNED_ACCESS instead of
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS

;)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index e644b3489acf..ea6872633a92 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1244,7 +1244,7 @@ static inline int nla_validate_nested(const struc=
t nlattr *start, int maxtype,
  */
 static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
 {
-#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
 		struct nlattr *attr =3D nla_reserve(skb, padattr, 0);
 		if (!attr)
@@ -1261,7 +1261,7 @@ static inline int nla_align_64bit(struct sk_buff =
*skb, int padattr)
 static inline int nla_total_size_64bit(int payload)
 {
 	return NLA_ALIGN(nla_attr_size(payload))
-#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 		+ NLA_ALIGN(nla_attr_size(0))
 #endif
 		;
