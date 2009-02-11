From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] IRDA: cnt is off by 1
Date: Wed, 11 Feb 2009 22:22:21 +0100
Message-ID: <4993418D.5020700@gmail.com>
References: <20090211133341.GB12362@ff.dom.local> <4992DF3C.7070802@gmail.com> <20090211171403.GA2539@ami.dom.local> <49932805.7050309@gmail.com> <20090211202755.GA2550@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, samuel@sortiz.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:22338 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756798AbZBKVWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:22:17 -0500
Received: by nf-out-0910.google.com with SMTP id d21so37782nfb.21
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 13:22:14 -0800 (PST)
In-Reply-To: <20090211202755.GA2550@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:

> Roel, please resend once more, but separated: something could go to
> stable, but not necessarily together. 

Ok, Here's for irda:

------------------------------>8----------------8<------------------------------
If no prior break occurs, cnt reaches 101 after the loop, so we are still able
to change speed when cnt has become 100.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 7eafdca..85e88da 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -585,7 +585,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
 	} while(cnt++ < 100 && (rval & MCS_IRINTX));
 
-	if(cnt >= 100) {
+	if (cnt > 100) {
 		IRDA_ERROR("unable to change speed\n");
 		ret = -EIO;
 		goto error;
