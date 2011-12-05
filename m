From: Li Wei <lw@cn.fujitsu.com>
Subject: ipv6: addrconf_add_mroute() problem with loopback interface.
Date: Mon, 05 Dec 2011 10:57:45 +0800
Message-ID: <4EDC3329.1040801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49219 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753401Ab1LEC5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 21:57:39 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 8C736170091
	for <netdev@vger.kernel.org>; Mon,  5 Dec 2011 10:57:27 +0800 (CST)
Received: from mailserver.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id pB52vQ7f005071
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 10:57:27 +0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

addrconf_add_mroute() create "default" multicast route for the interface, 
but with loopback interface, there would be some problem:

If we set ipv6 address for the "lo" interface *before* other interfaces, the
function addrconf_add_mroute() will create a "default" multicast route with
error set to ENETUNREACH for "lo" interface.

Later, when we send multicast packet, route subsystem will return this *error*
route, so no multicast packets can go out.

Does somebody can give me some advice that if it's necessary to add default
multicast route for loopback interface?
