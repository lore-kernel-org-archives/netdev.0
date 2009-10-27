From: Ben Greear <greearb@candelatech.com>
Subject: iproute uses too small of a receive buffer
Date: Tue, 27 Oct 2009 16:16:52 -0700
Message-ID: <4AE77F64.3090302@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000008090208070504050807"
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51679 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979AbZJ0XQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 19:16:48 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n9RNGrx8024494
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2009 16:16:53 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000008090208070504050807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I have a very busy system with a bunch of xorp router processes (mis)configured.

This thing is rapidly making route changes for whatever reason.

The 'ip monitor route' command was failing:

[root@i7-dqc-1 ]# ip monitor route
netlink receive error No buffer space available (105)
Dump terminated


It is only using a 32k rcv buffer, and it seems the OS was
overdriving it.

Please consider making the rcv buffer larger, perhaps something
like this (inline is white-space damaged...attachment should apply
if deemed useful.):

Signed-off-by:  Ben Greear <greearb@candelatech.com>

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..95a7d1d 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -38,7 +38,7 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions,
  {
         socklen_t addr_len;
         int sndbuf = 32768;
-       int rcvbuf = 32768;
+       int rcvbuf = 3276800;

         memset(rth, 0, sizeof(*rth));


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------000008090208070504050807
Content-Type: text/plain;
 name="iputils.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="iputils.patch"

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..95a7d1d 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -38,7 +38,7 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions,
 {
 	socklen_t addr_len;
 	int sndbuf = 32768;
-	int rcvbuf = 32768;
+	int rcvbuf = 3276800;
 
 	memset(rth, 0, sizeof(*rth));
 

--------------000008090208070504050807--
