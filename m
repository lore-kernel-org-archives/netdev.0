From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Tue, 01 Sep 2009 18:41:21 -0700 (PDT)
Message-ID: <20090901.184121.06750444.davem@davemloft.net>
References: <4A98132C.8090105@gmail.com>
	<20090828.233858.256193304.davem@davemloft.net>
	<4A9BBD8E.2010303@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755498AbZIBBlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 21:41:07 -0400
In-Reply-To: <4A9BBD8E.2010303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 Aug 2009 14:09:50 +0200

> Re-reading again this stuff, I realized ip6_push_pending_frames()
> was not updating IPSTATS_MIB_OUTDISCARDS, even if IP_RECVERR was set.
> 
> May I suggest following path :
> 
> 1) Correct ip6_push_pending_frames() to properly
> account for dropped-by-qdisc frames when IP_RECVERR is set

Your patch is  applied to net-next-2.6, thanks!

> 2) Submit a patch to account for qdisc-dropped frames in SNMP counters
> but still return a OK to user application, to not break them ?

Sounds good.

I think if you sample random UDP applications, you will find that such
errors will upset them terribly, make them log tons of crap to
/var/log/messages et al., and consume tons of CPU.

And in such cases silent ignoring of drops is entirely appropriate and
optimal, which supports our current behavior.

If we are to make such applications "more sophisticated" such
converted apps can be indicated simply their use of IP_RECVERR.

If you want to be notified of all asynchronous errors we can detect,
you use this, end of story.  It is the only way to handle this
situation without breaking the world.

As usual, Alexey Kuznetsov's analysis of this situation is timeless,
accurate, and wise.  And he understood all of this 10+ years ago.
