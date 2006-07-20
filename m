From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Oops in IFB
Date: Thu, 20 Jul 2006 15:33:28 +0200
Message-ID: <44BF8628.9080204@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080901080604020903030000"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.net-streams.fr ([62.23.133.110]:61964 "EHLO
	net-streams.fr") by vger.kernel.org with ESMTP id S1030302AbWGTNaV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 09:30:21 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080901080604020903030000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

When there is no memory left for creating all IFB devices (requesting
by user), a oops happens on the system.
Please find enclosed a patch to solve this.


Regards,
Nicolas


[IFB] After ifb_init_one() failed, i is increased. Decrease
it before entering in the loop for freeing the other ifb devices.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

--------------080901080604020903030000
Content-Type: text/x-patch;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

--- a/drivers/net/ifb.c	2006-07-20 15:16:31.923529050 +0200
+++ b/drivers/net/ifb.c	2006-07-20 15:17:36.370188249 +0200
@@ -271,6 +271,7 @@
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i); 
 	if (err) { 
+		i--;
 		while (--i >= 0)
 			ifb_free_one(i);
 	}

--------------080901080604020903030000--
