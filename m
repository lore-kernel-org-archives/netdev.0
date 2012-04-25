From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2012-04-25
Date: Wed, 25 Apr 2012 16:39:26 -0400 (EDT)
Message-ID: <20120425.163926.2209040699696617525.davem@davemloft.net>
References: <20120425191418.GC16900@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758960Ab2DYUkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 16:40:37 -0400
In-Reply-To: <20120425191418.GC16900@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 25 Apr 2012 15:14:19 -0400

> This is another batch of updates intended for 3.5...
 ...
> Please let me know if there are problems!

There are:

>From 792545c7bc5d6b922d3778dc602e557d64c83551 Mon Sep 17 00:00:00 2001
From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Date: Mon, 23 Apr 2012 19:55:48 -0700
Subject: [PATCH 88/88] libertas: include sched.h on firmware.c

Do not assume we have our subsystem including this for us,
at least for older kernels this is not true. Lets just be
explicit about this requirement for the usage of wake_up().

Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>

This is bogus, wake_up() is defined in linux/wait.h, the whole
point of the linux/sched.h split up is so that linux/sched.h
includes could be removed and replaced with actual dependencies.

Also, please don't accept any patches from Luis that add those
#undef pr_fmt things to the atheros drivers.

He tried to add it an ethernet driver, and I asked him to explain
exactly why he's doing and that if it's appropriate then it's
appropriate everywhere not just in a few specific drivers.  He failed
to respond to me, and therefore failed to explain the situation and
address my concerned.  And then I saw just today that he's submitting
the same patch to wireless drivers.  That's not acceptable.

Thanks.
