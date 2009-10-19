From: jamal <hadi@cyberus.ca>
Subject: [PATCH]: ingress socket filter by mark
Date: Mon, 19 Oct 2009 08:17:56 -0400
Message-ID: <1255954676.21059.7.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KDcTSkDgA4Z5dvqAwrYJ"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:38664 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbZJSMU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 08:20:59 -0400
Received: by pxi9 with SMTP id 9so1072541pxi.4
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 05:21:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KDcTSkDgA4Z5dvqAwrYJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

apps can specify mark that they want to accept/reject.

cheers,
jamal

--=-KDcTSkDgA4Z5dvqAwrYJ
Content-Disposition: attachment; filename=filt-sock-m-3
Content-Type: text/plain; name=filt-sock-m-3; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit ec187e3028db866161b881c5ac9eeea4e9bb0f1f
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Mon Oct 19 08:12:46 2009 -0400

    [PATCH]: ingress socket filter by mark
    
    Allow bpf to set a filter to drop packets that dont
    match a specific mark
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

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
 

--=-KDcTSkDgA4Z5dvqAwrYJ--

