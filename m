From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/3] s390/netiucv: get rid of one memcpy in netiucv_printuser
Date: Wed, 12 Oct 2016 12:38:49 +0200
Message-ID: <fc9696091325573020c1417c9d4ed010108f2172.1476263985.git.ursula.braun@de.ibm.com>
References: <cover.1476263985.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37298 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754121AbcJLKjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 06:39:39 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CAd9fb140860
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:39:12 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
        by mx0a-001b2d01.pphosted.com with ESMTP id 261eu9dxq1-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:39:12 -0400
Received: from localhost
        by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 12 Oct 2016 11:38:57 +0100
In-Reply-To: <cover.1476263985.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1476263985.git.ursula.braun@de.ibm.com>
References: <cover.1476263985.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save a memcpy in netiucv_printuser().

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reported-by: David Binderman <dcb314@hotmail.com>
---
 drivers/s390/net/netiucv.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index b0e8ffd..88b6e9c 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -302,8 +302,7 @@ static char *netiucv_printuser(struct iucv_connection *conn)
 	if (memcmp(conn->userdata, iucvMagic_ebcdic, 16)) {
 		tmp_uid[8] = '\0';
 		tmp_udat[16] = '\0';
-		memcpy(tmp_uid, conn->userid, 8);
-		memcpy(tmp_uid, netiucv_printname(tmp_uid, 8), 8);
+		memcpy(tmp_uid, netiucv_printname(conn->userid, 8), 8);
 		memcpy(tmp_udat, conn->userdata, 16);
 		EBCASC(tmp_udat, 16);
 		memcpy(tmp_udat, netiucv_printname(tmp_udat, 16), 16);
-- 
2.8.4
