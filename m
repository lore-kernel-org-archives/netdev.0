From: Dave Jones <davej@redhat.com>
Subject: [rfc] suspicious indentation in do_tcp_setsockopt
Date: Thu, 5 Sep 2013 00:20:45 -0400
Message-ID: <20130905042045.GD15824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756464Ab3IEEUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 00:20:53 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r854KrYq011223
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 5 Sep 2013 00:20:53 -0400
Received: from gelk.kernelslacker.org (ovpn-113-166.phx2.redhat.com [10.3.113.166])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r854KluZ010962
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 5 Sep 2013 00:20:53 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id r854KkPB021876
	for <netdev@vger.kernel.org>; Thu, 5 Sep 2013 00:20:46 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r854Kj5B021875
	for netdev@vger.kernel.org; Thu, 5 Sep 2013 00:20:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What's the intent here ?

This ?


diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b2f6c74..95544e4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2454,10 +2454,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_THIN_DUPACK:
 		if (val < 0 || val > 1)
 			err = -EINVAL;
-		else
+		else {
 			tp->thin_dupack = val;
 			if (tp->thin_dupack)
 				tcp_disable_early_retrans(tp);
+		}
 		break;
 
 	case TCP_REPAIR:

Or this ...

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b2f6c74..187c5a4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2456,8 +2456,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			err = -EINVAL;
 		else
 			tp->thin_dupack = val;
-			if (tp->thin_dupack)
-				tcp_disable_early_retrans(tp);
+
+		if (tp->thin_dupack)
+			tcp_disable_early_retrans(tp);
 		break;
 
 	case TCP_REPAIR:


I'll submit the right patch in the right form once I know what was intended.

The former seems more 'correct' to me, but I'm unsure if that could break something.

	Dave
