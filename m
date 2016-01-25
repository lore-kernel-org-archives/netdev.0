From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pptp: fix illegal memory access caused by multiple
 bind()s
Date: Sun, 24 Jan 2016 22:18:59 -0800 (PST)
Message-ID: <20160124.221859.411528121283723172.davem@davemloft.net>
References: <1453423183-4211-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru, sasha.levin@oracle.com,
	dvyukov@google.com, davej@codemonkey.org.uk
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbcAYGTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 01:19:01 -0500
In-Reply-To: <1453423183-4211-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 22 Jan 2016 01:39:43 +0100

> Several times already this has been reported as kasan reports caused by
> syzkaller and trinity and people always looked at RCU races, but it is
> much more simple. :)
> 
> In case we bind a pptp socket multiple times, we simply add it to
> the callid_sock list but don't remove the old binding. Thus the old
> socket stays in the bucket with unused call_id indexes and doesn't get
> cleaned up. This causes various forms of kasan reports which were hard
> to pinpoint.
> 
> Simply don't allow multiple binds and correct error handling in
> pptp_bind. Also keep sk_state bits in place in pptp_connect.
> 
> Fixes: 00959ade36acad ("PPTP: PPP over IPv4 (Point-to-Point Tunneling Protocol)")
> Cc: Dmitry Kozlov <xeb@mail.ru>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Dave Jones <davej@codemonkey.org.uk>
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks Hannes.
