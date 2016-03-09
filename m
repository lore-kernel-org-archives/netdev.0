From: Jonathan Thibault <jonathan@navigue.com>
Subject: gretap default MTU question
Date: Wed, 9 Mar 2016 12:25:35 -0500
Message-ID: <56E05C8F.1060901@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:40813 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932950AbcCIReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 12:34:03 -0500
Received: from [192.168.7.182] (unknown [74.117.40.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.navigue.com (Postfix) with ESMTPSA id 8553C1A003E
	for <netdev@vger.kernel.org>; Wed,  9 Mar 2016 12:25:35 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello good people of netdev,

When setting up gretap devices like so:

ip link add mydev type gretap remote 1.1.1.1 local 2.2.2.2 nopmtudisc

I'm observing two different behavior:

- On system A, the MTU of 'mydev' is set to the MTU of the 'parent'
interface (currently 1600) minus 38. All other interfaces on that system
have a default MTU of 1500, only the parent was forced to 1600 to avoid
fragmentation.  So 'mydev' accurately figures out that its MTU is 1562.

- On system B, with the 'parent' interface MTU set to 1600 and all other
defaulting to 1500 (same situation as A), the MTU of 'mydev' gets set to
1462.

I'm trying to figure out which behavior is normal and what mechanism (if
any) causes the MTU to be set differently.  In both cases the 'parent'
device has an MTU of 1600.  The code in ip_gre.c does this:

dev->mtu = ETH_DATA_LEN - t_hlen - 4;

In this case, system B would have the expected behavior and I need some
way to explain what goes on with system A.

Of course I can force the MTU on system B but I was rather pleased with
the 'magic' on system A.

If anyone here familiar with this code can offer an explanation, it
would greatly ease my curiosity.

Jonathan
