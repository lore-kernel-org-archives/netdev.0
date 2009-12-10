From: David Miller <davem@davemloft.net>
Subject: RT metric sharing...
Date: Thu, 10 Dec 2009 14:14:38 -0800 (PST)
Message-ID: <20091210.141438.78359022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761756AbZLJWOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 17:14:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D428724C6E2
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 14:14:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This topic has come up a few times, but I had a reason to
consider it again.

The routing metrics take up quite a bit of space in the
dst_entry and thus every routing cache entry.

We could save some space with indirection.

Basically my idea is:

1) dst_metrics are maintained in external structure

2) when cache entry is created, read-only dst_metrics object
   is allocated for it

3) any attempt to change the metrics of such a read-only dst_entry
   cow's it, all further writes proceed as normal

We currently have 13 (so 13 * sizeof(u32) == 52) and we're probably
about to get a 14th (for the initial receive window stuff).

