From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/13] s390/drivers: use setup_timer
Date: Wed, 18 Oct 2017 17:40:14 +0200
Message-ID: <20171018154025.73630-3-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58578 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751603AbdJRPkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:41 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdZ8h043675
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:41 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp769hb5v-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:41 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:39 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allen Pais <allen.lkml@gmail.com>

Use setup_timer function instead of initializing timer with the
function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/fsm.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/fsm.c b/drivers/s390/net/fsm.c
index e5dea67f902e..8c14c6c3ad3d 100644
--- a/drivers/s390/net/fsm.c
+++ b/drivers/s390/net/fsm.c
@@ -170,9 +170,7 @@ fsm_addtimer(fsm_timer *this, int millisec, int event, void *arg)
 	       this->fi->name, this, millisec);
 #endif
 
-	init_timer(&this->tl);
-	this->tl.function = (void *)fsm_expire_timer;
-	this->tl.data = (long)this;
+	setup_timer(&this->tl, (void *)fsm_expire_timer, (long)this);
 	this->expire_event = event;
 	this->event_arg = arg;
 	this->tl.expires = jiffies + (millisec * HZ) / 1000;
@@ -191,9 +189,7 @@ fsm_modtimer(fsm_timer *this, int millisec, int event, void *arg)
 #endif
 
 	del_timer(&this->tl);
-	init_timer(&this->tl);
-	this->tl.function = (void *)fsm_expire_timer;
-	this->tl.data = (long)this;
+	setup_timer(&this->tl, (void *)fsm_expire_timer, (long)this);
 	this->expire_event = event;
 	this->event_arg = arg;
 	this->tl.expires = jiffies + (millisec * HZ) / 1000;
-- 
2.13.5
