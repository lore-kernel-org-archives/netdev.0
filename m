From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] socket sk_sndmsg_page waste
Date: Tue, 06 Dec 2011 07:53:36 +0100
Message-ID: <1323154416.2467.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45147 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080Ab1LFGxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 01:53:40 -0500
Received: by eaak14 with SMTP id k14so4776071eaa.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 22:53:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP can steer one page of memory per socket to cook outgoing frames.

This means a machine handling long living sockets can consume a lot of
ram.

1.000.000 tcp sockets : up to 4GB of allocated memory, if some writes
had been done on these sockets.

It would make sense to use a per thread page as a pool, instead of a per
socket pool, and remove sk_sndmsg_page/off fields.

Problem with this strategy is impact outside of net tree, and a cost at
thread creation/destruction.

[ But this could be used in fs/pipe.c or fs/splice.c code..., so that
small writes() dont allocate a full page but try to reuse the "per
task_struct" page ]
