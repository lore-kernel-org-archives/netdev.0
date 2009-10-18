From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][RFC]: ingress socket filter by mark
Date: Sun, 18 Oct 2009 16:28:00 -0400
Message-ID: <1255897680.4815.63.camel@dogo.mojatatu.com>
References: <1255869758.4815.40.camel@dogo.mojatatu.com>
	 <4ADB5043.7070707@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PGA+Fb1QuH6vwR0kjwOa"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Atis Elsts <atis@mikrotik.com>,
	"Maciej Z.enczykowski" <zenczykowski@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:58853 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754949AbZJRUbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 16:31:02 -0400
Received: by qyk32 with SMTP id 32so2601494qyk.4
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 13:31:07 -0700 (PDT)
In-Reply-To: <4ADB5043.7070707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PGA+Fb1QuH6vwR0kjwOa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2009-10-18 at 19:28 +0200, Eric Dumazet wrote:

> I vote for extending BPF, and not adding the price of a compare
> for each packet. Only users wanting mark filtering should pay the price.

To be honest it nagged me as well;->
So here's a basic patch stolen from a patch i just saw that you
posted;-> I still havent tested. Let me know if it looks reasonable...

cheers,
jamal

--=-PGA+Fb1QuH6vwR0kjwOa
Content-Disposition: attachment; filename=filt-sock-m-2
Content-Type: text/x-patch; name=filt-sock-m-2; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1354aaf..909193e 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -123,7 +123,8 @@ struct sock_fprog	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_IFINDEX 	8
 #define SKF_AD_NLATTR	12
 #define SKF_AD_NLATTR_NEST	16
-#define SKF_AD_MAX	20
+#define SKF_AD_MARK 	20
+#define SKF_AD_MAX	24
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index d1d779c..e3987e1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -303,6 +303,9 @@ load_b:
 		case SKF_AD_IFINDEX:
 			A = skb->dev->ifindex;
 			continue;
+		case SKF_AD_MARK:
+			A = skb->mark;
+			continue;
 		case SKF_AD_NLATTR: {
 			struct nlattr *nla;
 

--=-PGA+Fb1QuH6vwR0kjwOa--

