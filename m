From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: Latest iproute2 breaks "ip route get" command
Date: Sun, 8 Aug 2010 21:33:04 +0200
Message-ID: <20100808193304.GA15380@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Fabio Comolli <fabio.comolli@gmail.com>,
	Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h31.telenor.se ([213.150.131.4]:55632 "EHLO
	smtprelay-h31.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab0HHTYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 15:24:38 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h31.telenor.se (Postfix) with ESMTP id 5F1B4EB5AA
	for <netdev@vger.kernel.org>; Sun,  8 Aug 2010 21:24:36 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The following logs should explain the problem. In short, the "ip route
> get" command with iproute2 v. 2.6.35 does not output anything (and
> exits with a 0). This breaks (for example) vpnc.

Seems to be caused by:

http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff;h=447928279c88b6581ae4cdc1b5ac0a9e755aff64

Have no idea if this is the correct fix, but it seemed like a likely typo
based on the changes in the above commit and that this brings the output back:


diff --git a/ip/iproute.c b/ip/iproute.c
index 711576e..86c7ab7 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -160,7 +160,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
 		ip6_multiple_tables = 1;
 
-	if (filter.cloned == !(r->rtm_flags&RTM_F_CLONED))
+	if (filter.cloned && !(r->rtm_flags&RTM_F_CLONED))
 		return 0;
 
 	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {



(PS. Sorry for not properly replying in thread, but todays mailing list
archives seems to be extremely afraid of exposing any real mail headers
making it hard to reply properly without having received the original mail.)

-- 
Andreas Henriksson
