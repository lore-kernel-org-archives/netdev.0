From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
 correctly
Date: Fri, 21 Dec 2007 22:58:04 +0900 (JST)
Message-ID: <20071221.225804.129665785.yoshfuji@linux-ipv6.org>
References: <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
	<20071221.175352.77874691.yoshfuji@linux-ipv6.org>
	<d72b7ace0712210549u51043bf8k585fd70e1ded7d8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: satoru.satoh@gmail.com, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44245 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbXLUN52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 08:57:28 -0500
In-Reply-To: <d72b7ace0712210549u51043bf8k585fd70e1ded7d8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <d72b7ace0712210549u51043bf8k585fd70e1ded7d8a@mail.gmail.com> (at Fri, 21 Dec 2007 22:49:59 +0900), "Satoru SATOH" <satoru.satoh@gmail.com> says:

> I agree.
> 
> I mistakenly thought hz in that context must be larger than 1000..
> As it's uncertain, your's looks much simpler and better.
> 
> (btw, the lines "else .... div = 1" is not needed, is it?)

Simplest fix is as follows:

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
--
diff --git a/ip/iproute.c b/ip/iproute.c
index f4200ae..7a885b0 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -509,7 +509,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			    i != RTAX_RTO_MIN)
 				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
 			else {
-				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
+				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
 
 				val *= 1000;
 				if (i == RTAX_RTT)
@@ -517,7 +517,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				else if (i == RTAX_RTTVAR)
 					val /= 4;
 				if (val >= hz)
-					fprintf(fp, " %ums", val/hz);
+					fprintf(fp, " %llums", val/hz);
 				else
 					fprintf(fp, " %.2fms", (float)val/hz);
 			}

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
