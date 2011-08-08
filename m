From: David Miller <davem@davemloft.net>
Subject: Re: return of ip_rt_bug()
Date: Sun, 07 Aug 2011 22:20:42 -0700 (PDT)
Message-ID: <20110807.222042.1034530719366562334.davem@davemloft.net>
References: <CAFiZG+Ve9Y4v9CWCrbGsR+7C79AyoiWncVSVbeqApDuKaPm_jA@mail.gmail.com>
	<CAFiZG+VJ27939BT-dTbvSotxO6+ACbxWiYwQBUT9pC_Fw22O-w@mail.gmail.com>
	<alpine.LFD.2.00.1108070104440.1413@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: selinux@gmail.com, davej@redhat.com, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab1HHFUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:20:51 -0400
In-Reply-To: <alpine.LFD.2.00.1108070104440.1413@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 7 Aug 2011 01:14:22 +0300 (EEST)

> 	The problem: if we have input route in the cache
> it can be returned to callers that request output route.
> That is why dst_output points to ip_rt_bug.

Good spotting Julian.

This is my fault entirely.  First I removed the thing we now call
->rt_route_iif which led to bug fix:

commit 1b86a58f9d7ce4fe2377687f378fbfb53bdc9b6c
Author: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date:   Thu Apr 7 14:04:08 2011 -0700

    ipv4: Fix "Set rt->rt_iif more sanely on output routes."

but I forgot to make sure we also added back the key comparison
on lookups as well :-/

Applied and queued up for -stable, thanks!

