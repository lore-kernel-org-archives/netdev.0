From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] ipv6: rt6_update_expires() seems racy
Date: Mon, 18 Feb 2013 15:55:18 -0800
Message-ID: <1361231718.19353.117.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Gao feng <gaofeng@cn.fujitsu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Bohac <jbohac@suse.cz>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:64491 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757550Ab3BRXzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 18:55:21 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so2664413dan.37
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 15:55:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some strange crashes happen in rt6_check_expired(), with access
to random addresses.

At first glance, it looks like the RTF_EXPIRES and
stuff added in commit 1716a96101c49186b
(ipv6: fix problem with expired dst cache)
are racy : same dst could be manipulated at the same time
on different cpus.

At some point, our stack believes rt->dst.from contains a dst pointer,
while its really a jiffie value (as rt->dst.expires shares the same area
of memory)

rt6_update_expires() should be fixed, or am I missing something ?

CC Neil because of https://bugzilla.redhat.com/show_bug.cgi?id=892060
