From: jamal <hadi@cyberus.ca>
Subject: [RFC PATCH net-next-2.6]: xfrm: Introduce LINUX_MIB_XFRMFWDHDRERROR
Date: Wed, 17 Feb 2010 06:40:52 -0500
Message-ID: <1266406852.3799.7.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-UETSCRRbQQLnuwJCpJjY"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f178.google.com ([209.85.221.178]:65394 "EHLO
	mail-qy0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889Ab0BQLk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:40:57 -0500
Received: by qyk8 with SMTP id 8so1696701qyk.24
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 03:40:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UETSCRRbQQLnuwJCpJjY
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I had a hard time debugging some setup while testing xfrm by mark
in presence of traffic being forwarded as well as being locally 
terminated. This change helped narrow things down a little for me.
The danger is that it changes the /proc output which may break some
user space tool (thats why i have it as an RFC).

cheers,
jamal 

--=-UETSCRRbQQLnuwJCpJjY
Content-Disposition: attachment; filename="FwdHdrErr"
Content-Type: text/plain; name="FwdHdrErr"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit cba12a140f1c4cad34f55d1b01067c2d83ee0748
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Wed Feb 17 06:26:52 2010 -0500

    xfrm: Introduce LINUX_MIB_XFRMFWDHDRERROR
    
    XFRMINHDRERROR counter is ambigous when validating forwarding
    path. It makes it tricky to debug when you have both in and fwd
    validation.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 0f953fe..8522120 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -246,6 +246,7 @@ enum
 	LINUX_MIB_XFRMINNOPOLS,			/* XfrmInNoPols */
 	LINUX_MIB_XFRMINPOLBLOCK,		/* XfrmInPolBlock */
 	LINUX_MIB_XFRMINPOLERROR,		/* XfrmInPolError */
+	LINUX_MIB_XFRMFWDHDRERROR,		/* XfrmFwdHdrError*/
 	LINUX_MIB_XFRMOUTERROR,			/* XfrmOutError */
 	LINUX_MIB_XFRMOUTBUNDLEGENERROR,	/* XfrmOutBundleGenError */
 	LINUX_MIB_XFRMOUTBUNDLECHECKERROR,	/* XfrmOutBundleCheckError */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index eb870fc..916784d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2052,8 +2052,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 	int res;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
-		/* XXX: we should have something like FWDHDRERROR here. */
-		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMFWDHDRERROR);
 		return 0;
 	}
 
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index c083a4e..289992a 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -30,6 +30,7 @@ static const struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmInNoPols", LINUX_MIB_XFRMINNOPOLS),
 	SNMP_MIB_ITEM("XfrmInPolBlock", LINUX_MIB_XFRMINPOLBLOCK),
 	SNMP_MIB_ITEM("XfrmInPolError", LINUX_MIB_XFRMINPOLERROR),
+	SNMP_MIB_ITEM("XfrmFwdHdrError", LINUX_MIB_XFRMFWDHDRERROR),
 	SNMP_MIB_ITEM("XfrmOutError", LINUX_MIB_XFRMOUTERROR),
 	SNMP_MIB_ITEM("XfrmOutBundleGenError", LINUX_MIB_XFRMOUTBUNDLEGENERROR),
 	SNMP_MIB_ITEM("XfrmOutBundleCheckError", LINUX_MIB_XFRMOUTBUNDLECHECKERROR),

--=-UETSCRRbQQLnuwJCpJjY--

