From: Li Wei <lw@cn.fujitsu.com>
Subject: Problem with the first ICMP_REDIRECT message
Date: Wed, 30 Nov 2011 11:10:54 +0800
Message-ID: <4ED59EBE.1030403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60924 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab1K3DKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 22:10:41 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 7D090170080
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 11:10:34 +0800 (CST)
Received: from mailserver.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id pAU3AX9M022817
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 11:10:33 +0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, 

I am doing some tests on ICMP_REDIRECT messages and found that I never receive
the first ICMP_REDIRECT message, but the following REDIRECT messages was normal.

My test environment as follow:
three pc:
PC A:
	IP: 192.168.0.1 MAC: HW:0A
PC B:
	IP: 192.168.0.2 MAC: HW:0B
	module nf_nat loaded and at least one rule in nat table(rule content not concern)
PC C:
	IP: 192.168.0.3 MAC: HW:0C

enable ip forwarding on PC B:
# echo 1 > /proc/sys/net/ipv4/ip_forward

add a static arp on PC A:
# arp -s 192.168.0.3 HW:0B

ping 192.168.0.3 on PC A:
# ping -c1 192.168.0.3

I expect that PC A will receive a ICMP_REDIRECT message from PC B, but nothing
received.

ping three times 192.168.0.3 on PC A:
# ping -c3 192.168.0.3 

PC A got two ICMP_REDIRECT messages from PC B, the first one missing.

After some code search, I found in function nf_nat_icmp_reply_translation() the first
ICMP_REDIRECT message was droped because the ct->status is not IPS_NAT_DONE_MASK.


Does anyone has some suggestion?
