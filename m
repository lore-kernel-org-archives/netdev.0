From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH net-next-2.6]: xfrm: Introduce
 LINUX_MIB_XFRMFWDHDRERROR
Date: Thu, 18 Feb 2010 08:35:07 -0500
Message-ID: <1266500107.17794.167.camel@bigi>
References: <1266406852.3799.7.camel@bigi>
	 <20100217.134946.106752388.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qudqM8F4ikeLY2A85NOf"
Cc: nakam@linux-ipv6.org, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:39233 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754209Ab0BRNfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 08:35:12 -0500
Received: by qyk30 with SMTP id 30so7066434qyk.23
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 05:35:10 -0800 (PST)
In-Reply-To: <20100217.134946.106752388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qudqM8F4ikeLY2A85NOf
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2010-02-17 at 13:49 -0800, David Miller wrote:

> This should be fine, the tools just parse the lines individually
> as "string integer" pairs.
> 
> If you want to be super anal, add the new counter to the end of
> the array.

Ok, thanks - here is the updated patch.

cheers,
jamal

--=-qudqM8F4ikeLY2A85NOf
Content-Disposition: attachment; filename="FwdHdrErr2"
Content-Type: text/plain; name="FwdHdrErr2"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 9bc885a86cf4be134ddf09cec8113cde24bb5048
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Thu Feb 18 08:25:57 2010 -0500

    xfrm: Introduce LINUX_MIB_XFRMFWDHDRERROR
    
    XFRMINHDRERROR counter is ambigous when validating forwarding
    path. It makes it tricky to debug when you have both in and fwd
    validation.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 0f953fe..e28f5a0 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -257,6 +257,7 @@ enum
 	LINUX_MIB_XFRMOUTPOLBLOCK,		/* XfrmOutPolBlock */
 	LINUX_MIB_XFRMOUTPOLDEAD,		/* XfrmOutPolDead */
 	LINUX_MIB_XFRMOUTPOLERROR,		/* XfrmOutPolError */
+	LINUX_MIB_XFRMFWDHDRERROR,		/* XfrmFwdHdrError*/
 	__LINUX_MIB_XFRMMAX
 };
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2c5d931..4368e7b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2045,8 +2045,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 	int res;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
-		/* XXX: we should have something like FWDHDRERROR here. */
-		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMFWDHDRERROR);
 		return 0;
 	}
 
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 003f2c4..58d9ae0 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -41,6 +41,7 @@ static const struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmOutPolBlock", LINUX_MIB_XFRMOUTPOLBLOCK),
 	SNMP_MIB_ITEM("XfrmOutPolDead", LINUX_MIB_XFRMOUTPOLDEAD),
 	SNMP_MIB_ITEM("XfrmOutPolError", LINUX_MIB_XFRMOUTPOLERROR),
+	SNMP_MIB_ITEM("XfrmFwdHdrError", LINUX_MIB_XFRMFWDHDRERROR),
 	SNMP_MIB_SENTINEL
 };
 

--=-qudqM8F4ikeLY2A85NOf--

