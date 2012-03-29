From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 0/3] memcg: tcp memcontrol fixes.
Date: Thu, 29 Mar 2012 16:01:11 +0900
Message-ID: <4F7408B7.9090706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	kamezawa.hiroyu@jp.fujitsu.com
To: Glauber Costa <glommer@parallels.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:33353 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757964Ab2C2HCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 03:02:55 -0400
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7E7A43EE0BC
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:02:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 563BD45DE58
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:02:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 374FC45DE55
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:02:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C1031DB804D
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:02:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C40491DB8043
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:02:53 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm very sorry if you received this e-mail twice.
==
This series is 3 bugfixes for memcg's kmem.tcp memory controller.
Maybe this should go via network tree.
(CC akpm for noticing an ugly change in res_counter.)

All patches are generated onto today linus's git tree.

Brief description:

Patch  1/3 .... tcp memcontrol doesn't see memcg's use_hierarchy value. Fix it.

Patch  2/3 and 3/3 .... 
                Because tcp memcontrol doesn't do any accounting when limit=RESOUCE_MAX,
	        there will be account leakage when limit is changed. This can trigger
                WARN_ON() in res_counter which checks usage >= 0.

Patch 2/3  .... don't call static_key_slow_dec(&memcg_socket_limit_enabled) until
                a cgroup under accounted is destroyed.

Patch 3/3  .... add res_counter_uncharge_nowarn() to ignore leakage.

Thanks,
-Kame
