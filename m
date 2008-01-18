From: David Miller <davem@davemloft.net>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Fri, 18 Jan 2008 04:49:11 -0800 (PST)
Message-ID: <20080118.044911.64979691.davem@davemloft.net>
References: <20080116135957.4eb54958.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38778
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755599AbYARMtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 07:49:10 -0500
In-Reply-To: <20080116135957.4eb54958.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 16 Jan 2008 13:59:57 -0800

> net/sctp/sm_statefuns.c: In function 'sctp_sf_do_5_1C_ack':
> net/sctp/sm_statefuns.c:484: warning: 'error' may be used uninitialized in this function
> 
> It is not obvious that this is a false positive.

I'll check in the following for now.

Vlad, please take a look.

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b126751..6e12757 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -481,7 +481,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 	sctp_init_chunk_t *initchunk;
 	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
-	sctp_error_t error;
+	sctp_error_t error = SCTP_ERROR_NO_ERROR;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
