From: "Srivats P" <Srivats.P@conexant.com>
Subject: [PATCH] iproute2: Fix no default display of ip4ip6 tunnels
Date: Thu, 19 Feb 2009 12:06:33 +0530
Message-ID: <F33E0C3C2876A544ABD34CFBE345A4A40211E426D0@NDMBX01.bbnet.ad>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnxtsmtp4.conexant.com ([198.62.9.251]:41214 "EHLO
	cnxtsmtp4.conexant.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbZBSGxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 01:53:43 -0500
Received: from CPS (wsmx1.nb.conexant.com [157.152.185.16]) (using TLSv1 with cipher RC4-MD5 (
 128/128 bits)) (No client certificate requested) by cnxtsmtp4.conexant.com (Tumbleweed MailGate
 3.6.1) with ESMTP id 2DE89197F05E for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 22:36:12 -0800 (
 PST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srivats P. <srivats.p@conexant.com>

"ip -6 tunnel show" displays only ip6ip6 tunnels not ip4ip6 tunnels - it should display all irrespective of proto.

This is because the default tunnel proto is initialized to IPPROTO_IPV6 in ip6_tnl_parm_init() which is fine for a 'add' command but not for 'show'. This patch overrides proto with 0 signifying 'mode any' as the default in case of a 'show'.

Signed-off-by: Srivats P. <srivats.p@conexant.com>
---

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 8421983..0122974 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -335,6 +335,7 @@ static int do_show(int argc, char **argv)
         struct ip6_tnl_parm p;

        ip6_tnl_parm_init(&p, 0);
+       p.proto = 0;

         if (parse_args(argc, argv, &p) < 0)
                 return -1;

Conexant E-mail Firewall (Conexant.Com) made the following annotations
---------------------------------------------------------------------
********************** Legal Disclaimer **************************** 

"This email may contain confidential and privileged material for the sole use of the intended recipient. Any unauthorized review, use or distribution by others is strictly prohibited. If you have received the message in error, please advise the sender by reply email and delete the message. Thank you." 

********************************************************************** 

---------------------------------------------------------------------

