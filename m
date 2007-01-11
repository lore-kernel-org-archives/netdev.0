From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/4] [SCTP]: Set correct error cause value for missing
	parameters
Date: Thu, 11 Jan 2007 11:41:25 -0800
Message-ID: <1168544485.22592.18.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:58328 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbXAKTli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 14:41:38 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0BJfVdU024128
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:31 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l0BJfTWu260860
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:29 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0BJfT5B004593
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:29 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here is a set of 4 SCTP patches that fix minor protocol 
conformance issues found by Vlad when running a conformance
test suite.
Please consider them for inclusion in 2.6.20.

Thanks
Sridhar

[SCTP]: Set correct error cause value for missing parameters

sctp_process_missing_param() needs to use the SCTP_ERROR_MISS_PARAM
error cause value.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_make_chunk.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 167d888..ea0f8fa 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1562,7 +1562,7 @@ static int sctp_process_missing_param(const struct sctp_association *asoc,
 	if (*errp) {
 		report.num_missing = htonl(1);
 		report.type = paramtype;
-		sctp_init_cause(*errp, SCTP_ERROR_INV_PARAM,
+		sctp_init_cause(*errp, SCTP_ERROR_MISS_PARAM,
 				&report, sizeof(report));
 	}

--

