From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG] in inet6_create
Date: Mon, 05 Nov 2007 20:00:46 +0900 (JST)
Message-ID: <20071105.200046.69224507.yoshfuji@linux-ipv6.org>
References: <472A3218.20708@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: 12o3l@tiscali.nl, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37158 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbXKELAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 06:00:43 -0500
In-Reply-To: <472A3218.20708@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <472A3218.20708@tiscali.nl> (at Thu, 01 Nov 2007 21:07:52 +0100), Roel Kluin <12o3l@tiscali.nl> says:

> I got this bug recently, I am not sure whether this is related to any previously 
> reported ones. It was a recently pulled git kernel. Also I have been hacking my
> kernel a bit lately, but I think that I haven't got any changes in the currently
> running kernel.

Please try this.

-----
[IPV6]: Ensure to initialize inetsw6 array before we start accepting socket.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index ecbd388..9ecd41b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -789,6 +789,7 @@ static int __init inet6_init(void)
 	/* Register the socket-side information for inet6_create.  */
 	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
 		INIT_LIST_HEAD(r);
+	synchronize_net();
 
 	/* We MUST register RAW sockets before we create the ICMP6,
 	 * IGMP6, or NDISC control sockets.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
