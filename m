From: Dave Jones <davej@redhat.com>
Subject: silence some noisy printks in irda
Date: Thu, 4 Oct 2012 09:36:13 -0400
Message-ID: <20121004133613.GA2913@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281Ab2JDNgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 09:36:16 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q94DaFvc025322
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 09:36:15 -0400
Received: from gelk.kernelslacker.org (ovpn-113-100.phx2.redhat.com [10.3.113.100])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q94DaEMv006760
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 09:36:15 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q94DaEue007078
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 09:36:14 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q94DaDaM007029
	for netdev@vger.kernel.org; Thu, 4 Oct 2012 09:36:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fuzzing causes these printks to spew constantly.
Changing them to DEBUG statements is consistent with other usage in the file,
and makes them disappear when CONFIG_IRDA_DEBUG is disabled.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index bb738c9..b833677 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -468,7 +468,7 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 	notify_t notify;
 
 	if (self->tsap) {
-		IRDA_WARNING("%s: busy!\n", __func__);
+		IRDA_DEBUG(0, "%s: busy!\n", __func__);
 		return -EBUSY;
 	}
 
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 5c93f29..1002e33 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -440,7 +440,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 */
 	lsap = irlmp_open_lsap(stsap_sel, &ttp_notify, 0);
 	if (lsap == NULL) {
-		IRDA_WARNING("%s: unable to allocate LSAP!!\n", __func__);
+		IRDA_DEBUG(0, "%s: unable to allocate LSAP!!\n", __func__);
 		return NULL;
 	}
 
