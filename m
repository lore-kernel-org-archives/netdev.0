From: Michele Petrazzo - Unipex <michele.petrazzo@unipex.it>
Subject: Re: [patch] [iproute] ip exit, ip and tc line number
Date: Sat, 06 Mar 2010 19:56:53 +0100
Message-ID: <4B92A575.1030801@unipex.it>
References: <4B8D58D9.7050202@unipex.it> <20100303163028.21ef4194@nehalam>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030900050609040702010500"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.go-wipex.it ([89.202.235.7]:53379 "EHLO smtp.go-wipex.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754227Ab0CFS46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Mar 2010 13:56:58 -0500
Received: from unipex-local-server (unipex.wipex [172.16.20.247])
	by smtp.go-wipex.it (Postfix) with ESMTP id 16E2110B0073
	for <netdev@vger.kernel.org>; Sat,  6 Mar 2010 19:56:56 +0100 (CET)
Received: from [192.168.25.2] (unknown [192.168.25.2])
	by unipex-local-server (Postfix) with ESMTP id 496C8450867
	for <netdev@vger.kernel.org>; Sat,  6 Mar 2010 19:56:55 +0100 (CET)
In-Reply-To: <20100303163028.21ef4194@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030900050609040702010500
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> The force issue is a different problem so please split out that part
> and resubmit.


Attached.

Michele

--------------030900050609040702010500
Content-Type: text/x-diff;
 name="iproute.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute.diff"

commit b1875eb9564da302ba79c01746ec9cf391d0d593
Author: Michele Petrazzo <michele.petrazzo@unipex.it>
Date:   Sat Mar 6 19:45:27 2010 +0100

    Allow ip to process all the file passed with the -batch argument when
    is passed also the -force switch

    Signed-off-by: Michele Petrazzo <michele.petrazzo@unipex.it>

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e9256d9..8ec6cfd 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1014,7 +1014,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	}
 	if (l && matches(d, l) != 0) {
 		fprintf(stderr, "\"dev\" (%s) must match \"label\" (%s).\n", d, l);
-		exit(1);
+		return -1;
 	}
 
 	if (peer_len == 0 && local_len) {
@@ -1079,7 +1079,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	}
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
-		exit(2);
+		return -2;
 
 	return 0;
 }

--------------030900050609040702010500--
