From: Li Wei <lw@cn.fujitsu.com>
Subject: Is there any necessary to add multicast route for a loopback device?
Date: Wed, 30 Nov 2011 15:38:37 +0800
Message-ID: <4ED5DD7D.10908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53506 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753904Ab1K3Hi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 02:38:28 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id A550C17012D
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 15:38:17 +0800 (CST)
Received: from mailserver.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id pAU7cG9i008224
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 15:38:16 +0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I found that since Fedora 15, it use systemd as the 'init'. When systemd start 
it would config the ipv6 address(::1/128) for 'lo' and start it. While adding 
this address to 'lo', kernel will call addrconf_add_mroute() to set a multicast
route for 'lo' with rt->dst.error = -ENETUNREACH. After that, when I send multi-
cast message, the route subsystem return a route with .error set to NETUNREACH.

Is there any necessary to add multicast route for a loopback device? 
