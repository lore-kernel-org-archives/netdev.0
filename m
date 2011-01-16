From: Arthur Marsh <arthur.marsh@internode.on.net>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Sun, 16 Jan 2011 23:09:50 +1030
Message-ID: <4D32E716.2050005@internode.on.net>
References: <54347.1295168081@internode.on.net> <1295169670.3977.36.camel@edumazet-laptop> <alpine.LNX.2.01.1101161144350.8081@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010605040107010504050106"
To: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bld-mail20.adl6.internode.on.net ([150.101.137.105]:48786 "EHLO
	mail.internode.on.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752138Ab1APMj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 07:39:57 -0500
Received: from [192.168.1.100] (unverified [121.45.139.71])
	by mail.internode.on.net (SurgeMail 3.8f2) with ESMTP id 7661970-1927428
	for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 23:09:53 +1030 (CDT)
In-Reply-To: <alpine.LNX.2.01.1101161144350.8081@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010605040107010504050106
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Jan Engelhardt wrote, on 16/01/11 21:20:
 >
 > Le dimanche 16 janvier 2011 à 19:24 +1030, Arthur Marsh a écrit :
 >>
 >>> With kernels up to and including 2.6.37-git7, inbound telnetd-ssl
 >>> connections worked fine. With kernel 2.6.37-git9 and later inbound
 >>> telnetd-ssl connections failed, and on machine shut-down, there
 >>> were warning messages about daemons not return status.
 >
 > Which daemons are these? For reference, what distro do you happen
 > to use?

avahi-daemon (which gave multiple warning messages, hence I thought it 
may have been multiple packages)

I'm running Debian unstable with kernel.org kernels.

 >
 >>> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf
 >>>      netlink: test for all flags of the NLM_F_DUMP composite
 >
 > Each of the hunks in this commit is independent of another.
 > Would you mind bisecting these too?

Recompiling with the only the first patch (attached) resulted in a 
repeat of the problem.

Arthur.

--------------010605040107010504050106
Content-Type: text/x-patch;
 name="netlink1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="netlink1.patch"

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 750db57..a5f7535 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1820,7 +1820,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
+	if (kind == 2 && (nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		struct sock *rtnl;
 		rtnl_dumpit_func dumpit;
 
 

--------------010605040107010504050106--
