From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7]: Gradual conversion to sk_buff list-head..
Date: Mon, 22 Sep 2008 19:12:30 -0700 (PDT)
Message-ID: <20080922.191230.127783294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37169
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbYIWCMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:42 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 64435C8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As I mentioned in my INFO patch the other day I'm trying to convert
sk_buff to use list_head's.

To make the transition smoother I've started to hit places one by one
that directly reference the sk_buff_head list handling implementation
details and make them use only the provided interfaces.  I've added
new interfaces where necessary to add more parity with what
linux/list.h provides.

Of note is that there are now list splice interfaces, as well as a
"light weight" sk_buff_head initializer for on-stack local list
cases.

There is more to do, but once it's all handled it should be a matter
of only editing linux/skbuff.h and net/core/skbuff.c to perform the
final conversion.

The trickiest part so far is the PPP MP fragmentation reassembly code.
I converted ISDN's copy, and am working on ppp_generic.c's at the moment
in my local tree.

Really we shouldn't have two copies (their implementations are even
slightly different wrt. handling unfinished frames and sequence gaps).

But such consolidation is a task for later.

All of this is pushed to net-next-2.6, so if you encounter some errors
let me know and I'll get them fixed up as fast as possible.
