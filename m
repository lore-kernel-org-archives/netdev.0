From: Mike Saal <msaal@qacafe.com>
Subject: ss format bug
Date: Wed, 26 Aug 2015 11:59:17 -0400
Message-ID: <55DDE255.1010003@qacafe.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050601030602000906010902"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35428 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839AbbHZP7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 11:59:19 -0400
Received: by qgj62 with SMTP id 62so128940131qgj.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 08:59:18 -0700 (PDT)
Received: from chinacat.lan ([50.255.187.93])
        by smtp.googlemail.com with ESMTPSA id t105sm16691270qgd.5.2015.08.26.08.59.17
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 08:59:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050601030602000906010902
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi:

I found a formatting bug in the 4.1.1 ss command. The following line was 
incorrectly output due to passing a negative length to printf() when 
displaying the local address. In this instance hostapd does a "bind to 
device" on cdreth0 and then does a udp "in address any" port 67 bind. 
Please note the whitespace between the '*' and ' %cdreth0:67'

    'udp UNCONN 0 0 ** %cdreth0:67* *:* users:(("hostapd",pid=19241,fd=5))'

Attached is my patch for the bug fix, it might be prudent to add more 
guard code looking for negative length format codes.

Sincerely, Mike

--------------050601030602000906010902
Content-Type: text/x-patch;
 name="ss.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ss.patch"

diff -Nuar iproute2-4.1.1.orig/misc/ss.c iproute2-4.1.1/misc/ss.c
--- iproute2-4.1.1.orig/misc/ss.c	2015-07-06 17:57:34.000000000 -0400
+++ iproute2-4.1.1/misc/ss.c	2015-08-20 10:37:17.615100588 -0400
@@ -1023,6 +1023,8 @@
 	if (ifindex) {
 		ifname   = ll_index_to_name(ifindex);
 		est_len -= strlen(ifname) + 1;  /* +1 for percent char */
+		if (est_len < 0)
+			est_len = 0;
 	}
 
 	sock_addr_print_width(est_len, ap, ":", serv_width, resolve_service(port),



--------------050601030602000906010902--
