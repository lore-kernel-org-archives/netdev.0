From: "Holden Karau" <holden@pigscanfly.ca>
Subject: [PATCH] 2.6.18 atmel iwlist stats patch
Date: Thu, 28 Sep 2006 14:22:30 -0400
Message-ID: <f46018bb0609281122l6998bed8raacd50a353c3c3fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	atmelwlandriver-devel@lists.sourceforge.net, holdenk@xandros.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:33205 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751939AbWI1SWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 14:22:31 -0400
Received: by wr-out-0506.google.com with SMTP id i7so216994wra
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 11:22:30 -0700 (PDT)
To: simon@thekelleys.org.uk
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Holden Karau <holden@pigscanfly.ca> http://www.holdenkarau.com

I have made a small patch for the atmel driver [included in the 2.6.18
kernel] to output signal strength information as part of iwlist scan
[before it did not output any signal strength related information].
Signed-off-by: Holden Karau <holden@pigscanfly.ca> http://www.holdenkarau.com
--
The output of iwlist scan is frequently used by user space utilites to
chose which wireless network to connect to based on the reported
signal strength, so I think this could be useful [of course I could be
horribly wrong about that but *shrugs*]. Incase the patch gets mangled
I've also put it up on at
http://www.holdenkarau.com/~holden/projects/atmel/patches/001-iwlist-stats.patch
And now for the patch:
--- drivers/net/wireless/atmel.c.orig	2006-09-28 14:14:42.000000000 -0400
+++ drivers/net/wireless/atmel.c	2006-09-28 14:14:55.000000000 -0400
@@ -2345,6 +2345,14 @@ static int atmel_get_scan(struct net_dev
 		iwe.u.freq.e = 0;
 		current_ev = iwe_stream_add_event(current_ev, extra +
IW_SCAN_MAX_DATA, &iwe, IW_EV_FREQ_LEN);

+		/* Add quality statistics */
+		iwe.cmd = IWEVQUAL;
+		iwe.u.qual.level = (__u8) priv->BSSinfo[i].RSSI;
+		iwe.u.qual.qual  = iwe.u.qual.level;
+		/* iwe.u.qual.noise  = SOMETHING */
+		current_ev = iwe_stream_add_event(current_ev, extra +
IW_SCAN_MAX_DATA , &iwe, IW_EV_QUAL_LEN);
+
+
 		iwe.cmd = SIOCGIWENCODE;
 		if (priv->BSSinfo[i].UsingWEP)
 			iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
