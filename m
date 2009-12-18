From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [3/5]
Date: Fri, 18 Dec 2009 12:27:13 +0100
Message-ID: <4B2B6711.3030305@yahoo.it>
References: <4B2B5A26.8050400@uniroma2.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030207090007020303000607"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:32772 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbZLRL1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 06:27:16 -0500
Received: by fxm21 with SMTP id 21so2700692fxm.21
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 03:27:15 -0800 (PST)
In-Reply-To: <4B2B5A26.8050400@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030207090007020303000607
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

patch 3/5 : iproute2-2.6.29-1/include/linux/pkt_sched.h

--------------030207090007020303000607
Content-Type: text/plain;
 name="tc_patch_3_of_5"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="tc_patch_3_of_5"

diff -uNr iproute2-2.6.29-1/include/linux/pkt_sched.h iproute2-2.6.29-1-netem/include/linux/pkt_sched.h
--- iproute2-2.6.29-1/include/linux/pkt_sched.h	2009-03-24 23:40:54.000000000 +0100
+++ iproute2-2.6.29-1-netem/include/linux/pkt_sched.h	2009-12-11 16:41:06.594482411 +0100
@@ -479,6 +479,21 @@
 	__u32	gap;		/* re-ordering gap (0 for none) */
 	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
 	__u32	jitter;		/* random jitter in latency (us) */
+	__u32	p13;		/* GI loss model-state 1 to 3 transition probability */
+	__u32	p31;		/* GI loss model-state 3 to 1 transition probability */
+	__u32	p32;		/* GI loss model-state 3 to 2 transition probability */
+	__u32	p23;		/* GI loss model-state 2 to 3 transition probability */
+	__u32   p14;		/* GI loss model-state 1 to 4 transition probability */
+	__u32	gilb_p;		/* Gilbert-Elliot model-state good-bad transition probability */
+	__u32	gilb_r;		/* Gilbert-Elliot model-state bad-good transition probability */
+	__u32	gilb_h;		/* Gilbert-Elliot-loss model loss probability in bad state */
+	__u32	gilb_k;		/* Gilbert-Elliot-loss model loss probability in good state */
+	__u32   algorithm;	/* loss model algorithm selection */
+	__u32 	logging;  	/* loss logging mode selector */
+	__u32   query;		/* loss query mode selector */
+	__u16   pattern_length; /* deterministic loss pattern length */
+	__u32   pattern_repetitions; /* deterministc loss pattern repetitions */
+	__u16   *user_pattern; /* determinist loss pattern elements */
 };
 
 struct tc_netem_corr

--------------030207090007020303000607--
