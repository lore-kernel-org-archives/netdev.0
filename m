From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation
 Needed message
Date: Fri, 01 Jun 2007 11:51:43 +0800
Message-ID: <465F97CF.1060508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:50571 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753402AbXFAD5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 23:57:54 -0400
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id E03841700BF
	for <netdev@vger.kernel.org>; Fri,  1 Jun 2007 11:57:30 +0800 (CST)
Received: from fnst.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id l513vTTr001180
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 11:57:30 +0800
Received: from [10.167.141.203] (unknown [10.167.141.203])
	by fnst.cn.fujitsu.com (Postfix) with ESMTP id 00FBAD4004
	for <netdev@vger.kernel.org>; Fri,  1 Jun 2007 12:07:38 +0800 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When received ICMP Fragmentation Needed message, PATH MTU is always set 
to the 576 even if MTU in ICMP message is lager then 576. This is 
because of error condition in function ip_rt_frag_needed(), now if 
packet size of that ICMP message is less then new MTU, packet size will 
be used ,but RFC says ICMP error message return as much as we can 
without exceeding 576 bytes.

This patch has Fixed this BUG.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- net/ipv4/route.c.orig	2007-05-25 05:22:47.000000000 +0800
+++ net/ipv4/route.c	2007-06-01 11:42:55.000000000 +0800
@@ -1424,7 +1424,7 @@ unsigned short ip_rt_frag_needed(struct 
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;
 
-				if (new_mtu < 68 || new_mtu >= old_mtu) {
+				if (new_mtu < 68) {
 
 					/* BSD 4.2 compatibility hack :-( */
 					if (mtu == 0 &&

