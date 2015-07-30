From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/3] ipv6: Turn on auto IPv6 flow labels by default
Date: Thu, 30 Jul 2015 09:54:19 -0700
Message-ID: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:62904 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750789AbbG3QzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 12:55:03 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6UGrjEq015136
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vypvy0aav-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:03 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 b83baff436db11e5be6f0002c99331b0-4aff52b0 for <netdev@vger.kernel.org>;	Thu,
 30 Jul 2015 09:55:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BSD (MacOS) has already turned on flow labels by default and this does
not seem to be causing any problems in the Internet. Let's go ahead
and turn them on by default. We'll continue to monitor for any devices
start choking on them.

Flow labels are important since they are the desired solution for
network devices to perform ECMP and RSS (RFC6437 and RFC6438).
Traditionally, devices perform a 5-tuple hash on packets that
includes port numbers. For the most part, these devices can only
compute 5-tuple hashes for TCP and UDP. This severely limits our ability
to get good network load balancing for other protocols (IPIP, GRE,ESP,
etc.), and hence we are limited in using other protocols. Unfortunately,
this method is accepted as the de facto standard to the extent that
there are several proposals to encapsulate protocols in UDP _just_ for
the purposes for getting ECMP to work. With hosts generating flow labels
and devices taking them as input into ECMP (several already do), we can
start to fix this fundamental problem. 

This patch set:
 - Changes IPV6_FLOWINFO sockopt to be opt-out of flow labels for
   connections rather than opt-in
 - Disable flow label state ranges sysctl by default
 - Enable auto flow labels sysctl by default


Tom Herbert (3):
  ipv6: Allow to connections to opt-out of flow labels
  ipv6: Disable flowlabel state ranges by default
  ipv6: Enable auto flow labels by default

 include/net/ipv6.h    | 2 +-
 net/ipv6/af_inet6.c   | 5 +++--
 net/ipv6/ip6_gre.c    | 4 ++--
 net/ipv6/ip6_tunnel.c | 2 +-
 4 files changed, 7 insertions(+), 6 deletions(-)

-- 
1.8.5.6
