From: Joe Perches <joe@perches.com>
Subject: RFC: Remove unnecessary / duplicate OOM printks
Date: Thu, 25 Aug 2011 13:47:23 -0700
Message-ID: <1314305243.4637.10.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wondertoys-mx.wondertoys.net ([206.117.179.246]:32787 "EHLO
	labridge.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754387Ab1HYUr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 16:47:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many thousands of printks for OOM conditions
in kernel sources.

These are almost always a duplication of a generic
OOM message from the mm subsystem.

The biggest difference between the generic OOM and
the specific OOM uses is that most of the specific
messages are emitted at KERN_ERR but the generic
message is at KERN_WARNING.

Many KB of code/text could be removed from the kernel.

Removal can be gradual and done by subsystem.

Some kmalloc's that are followed on failure by vmalloc
may need to add GFP_NOWARN.

Does anyone really believe the per site failure
messages are useful or really want them to keep them?
