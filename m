From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: xt_hashlimit.c race?
Date: Tue, 18 Sep 2012 17:22:15 +0400
Message-ID: <20201347974535@web11g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward18.mail.yandex.net ([95.108.253.143]:33640 "EHLO
	forward18.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757191Ab2IRNaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 09:30:08 -0400
Received: from web11g.yandex.ru (web11g.yandex.ru [95.108.252.111])
	by forward18.mail.yandex.net (Yandex) with ESMTP id 48FFE1781A37
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 17:22:17 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Looking at the net/netfilter/xt_hashlimit.c revealed one question. As far as
I can understand hashlimit_mt() code under rcu_read_lock_bh() can be
executed simultaneously by more than one CPU. So what if we have two
packets with the same new dst value that processed in parallel by different
CPUs? In both cases dh is NULL and both CPUs tries to create new
entry in hash table. This is not what we want and can lead to undefined
behavior in the future.

Or maybe I'm wrong? Could anyone tell me is this situation possible?

Thank you!

-- 
wbr, Oleg.
