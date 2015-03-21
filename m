From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] bonding work-queues, try_rtnl() &
 notifications
Date: Sat, 21 Mar 2015 18:17:00 -0400 (EDT)
Message-ID: <20150321.181700.1162404019090592599.davem@davemloft.net>
References: <1426916355-18289-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbCUWRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 18:17:13 -0400
In-Reply-To: <1426916355-18289-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Fri, 20 Mar 2015 22:39:15 -0700

> This patch series tries to address the issue discovered in various work-
> queues and the way these handlers deal with the RTNL. Especially for 
> notification handling. If RTNL can not be acquired, these handlers ignore
> sending notifications and just re-arm the timer. This could be very 
> problematic if the re-arm timer has larger value (e.g. in minutes).

I already made it very clear how I want this kind of problem solved.

Make the person holding the RTNL semaphore do the notification work
for you.

All of this deferral stuff is error prone and sloppy.
