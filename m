From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/4] [SCTP]: Verify some mandatory parameters.
Date: Wed, 17 Jan 2007 15:22:21 -0500
Message-ID: <45AE857D.8000208@hp.com>
References: <1168544487.22592.19.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060405010009010207040902"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:59614 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932738AbXAQUWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 15:22:25 -0500
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1168544487.22592.19.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060405010009010207040902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -462,24 +461,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,

> -	if (!init_tag) {
> -		struct sctp_chunk *reply = sctp_make_abort(asoc, chunk, 0);
> -		if (!reply)
> -			goto nomem;

This introduced a compiler warning, easily fixed.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------060405010009010207040902
Content-Type: text/x-patch;
 name="sctp_warn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sctp_warn.patch"

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index fce1f60..fbbc9e6 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -531,9 +531,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(c
 			SCTP_CHUNK(err_chunk));
 
 	return SCTP_DISPOSITION_CONSUME;
-
-nomem:
-	return SCTP_DISPOSITION_NOMEM;
 }
 
 /*

--------------060405010009010207040902--
