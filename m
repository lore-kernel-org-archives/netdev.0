From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rionet: Don't try to corrupt skbuff assigning data
 pointer directly
Date: Thu, 02 Jul 2015 12:12:04 -0700 (PDT)
Message-ID: <20150702.121204.1674202660204278751.davem@davemloft.net>
References: <5593E497.40804@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mporter@kernel.crashing.org,
	alexandre.bounine@idt.com, frank.kunz@nokia.com,
	marek.krzyzowski@nokia.com
To: alexander.sverdlin@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126AbbGBTMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 15:12:06 -0400
In-Reply-To: <5593E497.40804@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Date: Wed, 1 Jul 2015 15:01:11 +0200

> It's not allowed to assign data pointer of skbuff directly, this makes no sense
> if the assigned pointer is the very same as already existing one, or it brakes
> all the pointer arithmetics in all other cases. We cannot do better as just
> compare them and report BUG() in case of mismatch.
> 
> Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>

BUG takes the entire machine out, which is worse than corrupting the
skb->data

If you really want to assert this condition, do it in a way that
doesn't kill the entire machine.
