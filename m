From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Re: [PATCH net-next-2.6 1/2] mq: support for bonding
Date: Sun, 28 Feb 2010 11:25:13 +0300
Message-ID: <96591267345513@webmail87.yandex.ru>
References: <310461267277260@webmail48.yandex.ru> <1267288154.9082.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward13.mail.yandex.net ([95.108.130.120]:56475 "EHLO
	forward13.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031496Ab0B1IZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:25:15 -0500
In-Reply-To: <1267288154.9082.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

27.02.10, 17:29, "Eric Dumazet" <eric.dumazet@gmail.com>:

>  My dev machine has 16 cpus, and my network card has 16 queues per NIC

We should borrow this number from real device when enslaving it, picking
maximum value from among slaves. But the main problem is that we don't
known anything about slaves in bond_create() and there is no way to change
number of tx queues later. Maybe we could solve this by adding new module
parameter for bonding (num_tx_queues)?

>  Every xmit has to get this lock(s) and performance is not optimal.

You're right. I don't notice it. I see two solutions:

1) Convert all rw_locks to RCU mechanism
2) Use plain array instead of linked list to store list of slaves. In this case we
don't need to lock when doing bond_for_each_slave().

.. Or am I wrong? What do you think?

-- 
wbr, Oleg.
